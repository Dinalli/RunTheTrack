//
//  SettingsViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 06/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "SettingsViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    if(![CMMotionActivityManager isActivityAvailable])
//    {
//        motionView.hidden = YES;
//        m7TextView.hidden = NO;
//    }
}

-(IBAction)walkMetersChanged:(id)sender
{
    walkMeters.text = [NSString stringWithFormat:@"%.1f",walkSlider.value];
}

-(IBAction)runMetersChanged:(id)sender
{
    runMeters.text = [NSString stringWithFormat:@"%.1f",runSlider.value];
}

-(IBAction)gpsSwitched:(id)sender
{
    motionSwitch.on = NO;
    runSlider.enabled = NO;
    walkSlider.enabled = NO;
}

-(IBAction)m7switched:(id)sender
{
    gpsSwitch.on = NO;
    runSlider.enabled = YES;
    walkSlider.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
