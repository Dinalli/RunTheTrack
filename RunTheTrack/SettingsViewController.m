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
#import <Social/Social.h>

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
    if(![CMMotionActivityManager isActivityAvailable])
    {
        motionView.hidden = YES;
        [gpsSwitch setOn:YES];
        [gpsSwitch setEnabled:NO];
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self setUpDefaultsOnLoad];
}

-(void)setUpDefaultsOnLoad
{
    if([defaults valueForKey:@"gps"])
    {
        [gpsSwitch setOn:[[defaults valueForKey:@"gps"] boolValue]];
        [motionSwitch setOn:[[defaults valueForKey:@"motion"] boolValue]];
    }
    
    [units setSelectedSegmentIndex:[[defaults valueForKey:@"units"] integerValue]];
    
    [runSlider setValue:[[defaults valueForKey:@"runSliderValue"] floatValue]];
    runMeters.text = [NSString stringWithFormat:@"%.2f",runSlider.value];
    walkMeters.text = [NSString stringWithFormat:@"%.2f",walkSlider.value];
    
    [soundEnabled setOn:[[defaults valueForKey:@"sound"] boolValue]];
    
}

-(void)setDefaults
{
    [defaults setValue:[NSString stringWithFormat:@"%.2f",runSlider.value] forKey:@"runSliderValue"];
    [defaults setValue:[NSNumber numberWithBool:gpsSwitch.on] forKey:@"gps"];
    [defaults setValue:[NSNumber numberWithBool:motionSwitch.on] forKey:@"motion"];
    [defaults setValue:[NSNumber numberWithInteger:units.selectedSegmentIndex] forKey:@"units"];
    [defaults setValue:[NSNumber numberWithBool:motionSwitch.on] forKey:@"sound"];
    [defaults synchronize];
}

-(IBAction)runMetersChanged:(id)sender
{
    runMeters.text = [NSString stringWithFormat:@"%.2f",runSlider.value];
    [appDelegate setRunMotionDistance:runSlider.value];
    [self setDefaults];
}

-(IBAction)soundSwitched:(id)sender
{
    [appDelegate setSoundEnabled:soundEnabled.on];
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
    [appDelegate setRunMotionDistance:runSlider.value];
    [self setDefaults];
}

-(IBAction)unitSwitched:(id)sender
{
    [appDelegate setUseKMasUnits:units.selectedSegmentIndex];
    [self setDefaults];
}

#pragma mark social sharing

-(IBAction)feedback:(id)sender
{
    UIActionSheet *loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Contact using" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Uservoice" otherButtonTitles:@"twitter", nil];
    
    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self contactUserVoice];
    }
    else if (buttonIndex == 1) {
        [self shareOnTwitter];
    }
}

-(void)contactUserVoice
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://runthetrack.uservoice.com/"]];
}

-(void)shareOnTwitter
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [self composePost:SLServiceTypeTwitter];
    }
    else{
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Cannot load twitter"
                                                     description:@"Check your twitter settings now"
                                                            type:MessageBarMessageTypeInfo];
    }
}

-(void)composePost:(NSString *)serviceType
{
    SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
    composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
    [composeSheet setInitialText:@"@runthetracks - add your message here "];

    [self presentViewController:composeSheet animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
