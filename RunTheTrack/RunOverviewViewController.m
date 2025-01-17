//
//  RunMapViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunOverviewViewController.h"
#import "UIImage+ImageEffects.h"
#import "RunTrackMapViewController.h"
#import "CoreDataHelper.h"

@implementation RunOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
//    timeView.layer.masksToBounds = NO;
//    timeView.layer.shadowOffset = CGSizeMake(0,-3);
//    timeView.layer.shadowRadius = 2;
//    timeView.layer.shadowOpacity = 0.7;
//    timeView.layer.cornerRadius = 4;
//    timeView.layer.borderColor = [[UIColor blackColor] CGColor];
//    timeView.layer.borderWidth = 0.5;
//    
//    trackInfoView.layer.masksToBounds = NO;
//    trackInfoView.layer.shadowOffset = CGSizeMake(0,-3);
//    trackInfoView.layer.shadowRadius = 2;
//    trackInfoView.layer.shadowOpacity = 0.7;
//    trackInfoView.layer.cornerRadius = 4;
//    trackInfoView.layer.borderColor = [[UIColor blackColor] CGColor];
//    trackInfoView.layer.borderWidth = 0.5;
//    
//    runDetailsView.layer.masksToBounds = NO;
//    runDetailsView.layer.shadowOffset = CGSizeMake(0,-3);
//    runDetailsView.layer.shadowRadius = 2;
//    runDetailsView.layer.shadowOpacity = 0.7;
//    runDetailsView.layer.cornerRadius = 4;
//    runDetailsView.layer.borderColor = [[UIColor blackColor] CGColor];
//    runDetailsView.layer.borderWidth = 0.5;
    
    [self initFlatWithIndicatorProgressBar];
    [self.progressBarFlatWithIndicator setProgress:0.0001 animated:YES];
    
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    self.navigationController.navigationItem.title = self.runData.runtrackname;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActivityView:)];
    [self.navigationController.navigationItem setRightBarButtonItem:barButton];
    
//    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
//        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
//        {
//            self.trackInfo = trackInfoDict;
//            backgroundImageView.image = [[UIImage imageNamed:[trackInfoDict objectForKey:@"trackimage"]] applyDarkEffect];
//        }
//    }
    
    float laps = 0;
    int trackLapsCount = [[NSString stringWithFormat:@"%@",[self.trackInfo objectForKey:@"Laps"]] intValue];
    for (RunData *rd in runs) {
        if([rd.runtrackname isEqualToString:trackName.text])
        {
            laps = laps + [rd.runlaps floatValue];
        }
    }
    
    if(laps > 0)
    {
        CGFloat progress = (laps / trackLapsCount);
        [self setProgress:progress animated:YES];
    }
    else{
        [self setProgress:0.01 animated:YES];
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
    
    UIActionSheet *loginActionSheet;
    if([self.runData.runtype isEqualToString:@"GPSRun"])
    {
        
        loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter", @"go to track", nil];
    }
    else
    {
        loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter", nil];
    }
    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self shareOnFacebook];
    }
    else if (buttonIndex == 1) {
        [self shareOnTwitter];
    }
    else if (buttonIndex == 2)
    {
        [self goToTrack];
    }
}

- (NSString *)gpxFilePath
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.gpx",self.runData.runtrackname, dateString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathToFile = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    
    return pathToFile;
}

-(void)goToTrack
{
    [self performSegueWithIdentifier:@"RunTrackSegue" sender:self];
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
    else
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Share on Facebook"
                                                     description:@"Please make sure you are Logged In"
                                                            type:MessageBarMessageTypeInfo];
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
    else
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Share on Twitter"
                                                     description:@"Please make sure you are Logged In"
                                                            type:MessageBarMessageTypeInfo];
    }
}

-(void)composePost:(NSString *)serviceType
{
    shareButton.hidden = YES;
    SLComposeViewController *composeSheet=[[SLComposeViewController alloc]init];
    composeSheet=[SLComposeViewController composeViewControllerForServiceType:serviceType];
    [composeSheet setInitialText:[NSString stringWithFormat:@"Comepleted a run round the %@ GP track. %@ %@ %@ @runthetracks", self.navigationItem.title, runTime.text, runDistance.text, runLaps.text]];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
    shareButton.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunTrackSegue"]) {
        RunTrackMapViewController *rsvc = segue.destinationViewController;
        [rsvc setRunData:self.runData];
    }
}




@end
