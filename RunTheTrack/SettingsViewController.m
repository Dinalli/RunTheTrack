//
//  SettingsViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 06/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self setUpDefaultsOnLoad];
    
}

-(void)setUpDefaultsOnLoad
{
    [walkSlider setValue:[[defaults valueForKey:@"walkSliderValue"] floatValue]];
    [runSlider setValue:[[defaults valueForKey:@"runSliderValue"] floatValue]];
    
    if([defaults valueForKey:@"gps"])
    {
        [gpsSwitch setOn:[[defaults valueForKey:@"gps"] boolValue]];
        [motionSwitch setOn:[[defaults valueForKey:@"motion"] boolValue]];
    }
    
    [units setSelectedSegmentIndex:[[defaults valueForKey:@"units"] integerValue]];
    
    runMeters.text = [NSString stringWithFormat:@"%.1f",runSlider.value];
    walkMeters.text = [NSString stringWithFormat:@"%.1f",walkSlider.value];
    
}

-(void)setDefaults
{
    [defaults setValue:[NSString stringWithFormat:@"%f",walkSlider.value] forKey:@"walkSliderValue"];
    [defaults setValue:[NSString stringWithFormat:@"%f",runSlider.value] forKey:@"runSliderValue"];
    [defaults setValue:[NSNumber numberWithBool:gpsSwitch.on] forKey:@"gps"];
    [defaults setValue:[NSNumber numberWithBool:motionSwitch.on] forKey:@"motion"];
    [defaults setValue:[NSNumber numberWithInteger:units.selectedSegmentIndex] forKey:@"units"];
    [defaults synchronize];
}

-(IBAction)walkMetersChanged:(id)sender
{
    walkMeters.text = [NSString stringWithFormat:@"%.1f",walkSlider.value];
    [appDelegate setWalkMotionDistance:walkSlider.value];
    [self setDefaults];
}

-(IBAction)runMetersChanged:(id)sender
{
    runMeters.text = [NSString stringWithFormat:@"%.1f",runSlider.value];
    [appDelegate setRunMotionDistance:runSlider.value];
    [self setDefaults];
}

-(IBAction)gpsSwitched:(id)sender
{
    motionSwitch.on = NO;
    runSlider.enabled = NO;
    walkSlider.enabled = NO;
    
    [appDelegate setUseMotion:NO];
    [self setDefaults];
}

-(IBAction)m7switched:(id)sender
{
    gpsSwitch.on = NO;
    runSlider.enabled = YES;
    walkSlider.enabled = YES;
    
    [appDelegate setUseMotion:YES];
    [appDelegate setWalkMotionDistance:walkSlider.value];
    [appDelegate setRunMotionDistance:runSlider.value];
    [self setDefaults];
}

-(IBAction)unitSwitched:(id)sender
{
    [appDelegate setUseKMasUnits:units.selectedSegmentIndex];
    [self setDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
