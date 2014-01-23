//
//  SettingsViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 06/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@class AppDelegate;

@interface SettingsViewController : UIViewController
{
    IBOutlet UIView *motionView;
    IBOutlet UITextView *m7TextView;
    IBOutlet UISlider *walkSlider;
    IBOutlet UISlider *runSlider;
    IBOutlet UILabel *walkMeters;
    IBOutlet UILabel *runMeters;
    IBOutlet UISwitch *gpsSwitch;
    IBOutlet UISwitch *motionSwitch;
    IBOutlet UISegmentedControl *units;
    
    AppDelegate *appDelegate;
    NSUserDefaults *defaults;
    
    BOOL motionEnabled;
}

@end
