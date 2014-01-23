//
//  RunMapViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunOverviewViewController.h"
#import "UIImage+ImageEffects.h"

@implementation RunOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    timeView.layer.masksToBounds = NO;
    timeView.layer.shadowOffset = CGSizeMake(0,-3);
    timeView.layer.shadowRadius = 2;
    timeView.layer.shadowOpacity = 0.7;
    timeView.layer.cornerRadius = 4;
    timeView.layer.borderColor = [[UIColor blackColor] CGColor];
    timeView.layer.borderWidth = 0.5;
    
    trackInfoView.layer.masksToBounds = NO;
    trackInfoView.layer.shadowOffset = CGSizeMake(0,-3);
    trackInfoView.layer.shadowRadius = 2;
    trackInfoView.layer.shadowOpacity = 0.7;
    trackInfoView.layer.cornerRadius = 4;
    trackInfoView.layer.borderColor = [[UIColor blackColor] CGColor];
    trackInfoView.layer.borderWidth = 0.5;
    
    runDetailsView.layer.masksToBounds = NO;
    runDetailsView.layer.shadowOffset = CGSizeMake(0,-3);
    runDetailsView.layer.shadowRadius = 2;
    runDetailsView.layer.shadowOpacity = 0.7;
    runDetailsView.layer.cornerRadius = 4;
    runDetailsView.layer.borderColor = [[UIColor blackColor] CGColor];
    runDetailsView.layer.borderWidth = 0.5;
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [timeView addMotionEffect:group];
    [trackInfoView addMotionEffect:group];
    [runDetailsView addMotionEffect:group];
    [self initFlatWithIndicatorProgressBar];
    [self.progressBarFlatWithIndicator setProgress:0.4 animated:YES];
    
    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            self.trackInfo = trackInfoDict;
            trackMapImage.image = [UIImage imageNamed:[trackInfoDict objectForKey:@"mapimage"]];
        }
    }

    
    [self setUpRunData];
}

-(void)setUpRunData
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Track Info
    trackDistance.text = [self.trackInfo objectForKey:@"Distance"];
    trackName.text = [self.trackInfo objectForKey:@"Race"];
    trackLaps.text = [self.trackInfo objectForKey:@"Laps"];
    
    // Run Info
    
    runTime.text = self.runData.runtime;
    runType.text = self.runData.runtype;
    runLaps.text = self.runData.runlaps;
    runSteps.text = self.runData.runSteps;
    runPace.text = self.runData.runPace;
    runClimb.text = @"-";
    
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"%.02f km", [self.runData.rundistance floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"%.2f miles",[self.runData.rundistance floatValue] * 0.000621371192];
    }
    
    runDate.text = [NSString stringWithFormat:@"%@",self.runData.rundate];
    self.navigationItem.title = self.runData.runtrackname;
    
    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            self.trackInfo = trackInfoDict;
            backgroundImageView.image = [[UIImage imageNamed:[trackInfoDict objectForKey:@"trackimage"]] applyDarkEffect];
        }
    }
}

- (void)initFlatWithIndicatorProgressBar
{
    _progressBarFlatWithIndicator.type                     = YLProgressBarTypeFlat;
    _progressBarFlatWithIndicator.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _progressBarFlatWithIndicator.behavior                 = YLProgressBarBehaviorIndeterminate;
    _progressBarFlatWithIndicator.stripesOrientation       = YLProgressBarStripesOrientationVertical;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [_progressBarFlatWithIndicator setProgress:progress animated:animated];
}

#pragma mark social sharing

-(IBAction)showActivityView:(id)sender
{
    UIActionSheet *loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"facebook" otherButtonTitles:@"twitter", nil];
    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self shareOnFacebook];
    }
    else if (buttonIndex == 1) {
        [self shareOnTwitter];
    }
}

-(void)shareOnFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Share on facebook"
                                                     description:@"Creating the post now"
                                                            type:MessageBarMessageTypeInfo];
        [self composePost:SLServiceTypeFacebook];
    }
}

-(void)shareOnTwitter
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Share on twitter"
                                                     description:@"Creating the post now"
                                                            type:MessageBarMessageTypeInfo];
        [self composePost:SLServiceTypeTwitter];
    }
}

-(void)composePost:(NSString *)serviceType
{
    SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
    composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. %@ %@ %@ @runthetracks", self.navigationItem.title, runTime.text, runDistance.text, runLaps.text]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
}



@end
