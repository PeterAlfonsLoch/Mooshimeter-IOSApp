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

#import <UIKit/UIKit.h>
#import "BLEUtility.h"
#import "LegacyMooshimeterDevice.h"
#import "ChannelView.h"
#import "../MeterSettingsView.h"

@class ChannelView;

@interface MeterViewController : UIViewController <UISplitViewControllerDelegate>

// Housekeeping
@property bool play;
@property MooshimeterDeviceBase * meter;

// GUI widgets

@property (strong, nonatomic) ChannelView* ch1_view;
@property (strong, nonatomic) ChannelView* ch2_view;
@property (strong, nonatomic) UIButton* rate_auto_button;
@property (strong, nonatomic) UIButton* rate_button;
@property (strong, nonatomic) UIButton* depth_auto_button;
@property (strong, nonatomic) UIButton* depth_button;
@property (strong, nonatomic) UIButton* logging_button;
@property (strong, nonatomic) UIButton* zero_button;

//@property (strong, nonatomic) MeterSettingsView* settings_view;

-(instancetype)initWithMeter:(MooshimeterDeviceBase *)meter;
+(void)style_auto_button:(UIButton*)b on:(BOOL)on;

@end