/**************************
Mooshimeter iOS App - interface to Mooshimeter wireless multimeter
Copyright (C) 2015  James Whong

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***************************/

#import "LoggingPreferencesVC.h"
#import "WidgetFactory.h"
#import "PopupMenu.h"
#import "GCD.h"
#import "BlockWrapper.h"
#import "DownloadVC.h"
#import "SmartNavigationController.h"

@interface LogInfoRow:UIControl
@property UILabel* index_tv;
@property UILabel* endtime_tv;
@property UILabel* size_tv;
@end
@implementation LogInfoRow
-(instancetype)init {
    self = [super init];
    self.index_tv   = [[UILabel alloc]init];
    self.endtime_tv = [[UILabel alloc]init];
    self.size_tv    = [[UILabel alloc]init];
    [self.index_tv   setTextAlignment:UITextAlignmentCenter];
    [self.endtime_tv setTextAlignment:UITextAlignmentCenter];
    [self.size_tv    setTextAlignment:UITextAlignmentCenter];
    [self addSubview:self.index_tv];
    [self addSubview:self.endtime_tv];
    [self addSubview:self.size_tv];
    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    float fw = self.frame.size.width;
    float fh = self.frame.size.height;
    [self.index_tv setFrame:CGRectMake(   0,0,50,fh)];
    [self.endtime_tv setFrame:CGRectMake(50,0,fw-100,fh)];
    [self.size_tv setFrame:CGRectMake(fw-50,0,50,fh)];
}
@end

@implementation LoggingPreferencesVC {
}

////////////////////
// Lifecycle methods
////////////////////

-(instancetype)initWithMeter:(MooshimeterDeviceBase *)meter{
    self = [super init];
    self.meter = meter;
    [self.meter addDelegate:self];
    return self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.meter removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Logging Preferences"];

    // Logging enable
    DECLARE_WEAKSELF;
    UISwitch * logging_on_switch = [WidgetFactory makeSwitch:^(bool i) {
        [ws.meter setLoggingOn:i];
    }];
    [logging_on_switch setOn:[self.meter getLoggingOn] animated:YES];
    [self addPreferenceCell:@"Logging Enable" msg:@"Enables logging if SD card present" accessory:logging_on_switch];

    // Logging interval
    {
        NSString* title = [NSString stringWithFormat:@"%ds",([self.meter getLoggingIntervalMS]/1000)];
        UIButton* b = [WidgetFactory makeButtonReflexive:title callback:^(UIButton *button) {
            // Start a dialog box to get some input
            NSArray<NSString*>* s_options = @[@"MAX",@"1s",@"10s",@"1min"];
            NSArray<NSNumber*>* i_options = @[@0,@1000,@(10*1000),@(60*1000)];
            [PopupMenu displayOptionsWithParent:self.view
                                          title:@"Logging Interval"
                                        options:s_options callback:^(int i) {
                        [self.meter setLoggingInterval:[i_options[i] integerValue]];
                        [button setTitle:[NSString stringWithFormat:@"%ds", ([self.meter getLoggingIntervalMS] / 1000)] forState:UIControlStateNormal];
                    }];
        }];
        [b setFrame:CGRectMake(0,0,50,50)];
        [self addPreferenceCell:@"Logging Interval" msg:@"Set the time between samples when logging is on." accessory:b];
    }

    // Load logs button
    {
        UIButton* b = [WidgetFactory makeButtonReflexive:@"Load Logs" callback:^(UIButton *button) {
            [b setEnabled:NO];
            [GCD asyncBack:^{
                [ws.meter pollLogInfo];
            }];
        }];
        [self addCell:b];
    }
}

-(void)onLogInfoReceived:(LogFile *)log {
    DECLARE_WEAKSELF;
    [GCD asyncMain:^{
        LogInfoRow * row = [[LogInfoRow alloc]init];
        [row.index_tv setText:[NSString stringWithFormat:@"%u",log.index]];
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM:dd HH:mm"];
        [row.endtime_tv setText:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:log.end_time]]];
        [row.size_tv setText:[NSString stringWithFormat:@"%ukB",(log.bytes/1024)]];

        // Catch touches anywhere in the bar
        [[BlockWrapper alloc] initAndAttachTo:row forEvent:UIControlEventTouchUpInside callback:^{
            SmartNavigationController * gnav = [SmartNavigationController getSharedInstance];
            DownloadVC * vc = [[DownloadVC alloc] initWithLogfile:log];
            [gnav pushViewController:vc animated:YES];
        }];
        [self addCell:row];
    }];
}
@end
