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
#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Client.h"

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
        
        loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share using" delegate:self cancelButtonTitle:@"Cancel"  destructiveButtonTitle:@"share on facebook" otherButtonTitles:@"share on twitter",@"export to strava", @"go to track", nil];
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
        if([self.runData.runtype isEqualToString:@"GPSRun"])
        {
            [self exportToStrava];
        }
    }
    else if (buttonIndex == 3)
    {
        [self goToTrack];
    }
}


-(void)exportToStrava
{
    // Export Data to GPX format
    filePath = [self createGPX];
    
    if (filePath) {
        // Post to Strava
        
        [self loginToStrava];
    }
}


//-(void)loginToStrava:(NSString *)filePath
//{
//
//    //https://www.strava.com/oauth/authorize?response_type=code&redirect_uri=http://127.0.0.1&scope=view_private&approval_prompt=force&client_id=1401
//    
//    NSURL *url = [NSURL URLWithString:@"https://www.strava.com/oauth/"];
//    AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:url clientID:@"1401" secret:@"967b9297f6f1c9a0a8fe10a021cf211fa35b4d59"];
//    
//    [client authenticateUsingOAuthWithPath:@"authorize" username:@"Dinalli" password:@"BurtonUn1nc" scope:@"write"
//                                   success:^(AFOAuthCredential *credential) {
//                                       NSLog(@"Successfully received OAuth credentials %@", credential.accessToken);
//                                       [AFOAuthCredential storeCredential:credential
//                                                           withIdentifier:client.serviceProviderIdentifier];
//                                       [self postToStrava:filePath];
//                                   }
//                                   failure:^(NSError *error) {
//                                       NSLog(@"OAuth Error: %@", error);
//                                   }];
//}

-(void)loginToStrava
{
    [appDelegate addObserver:self forKeyPath:@"stravaCode"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
    
    NSURL *url = [NSURL URLWithString:@"https://www.strava.com"];
    AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:url clientID:@"1401" secret:@"967b9297f6f1c9a0a8fe10a021cf211fa35b4d59"];
    
    stravaWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    stravaWebView.delegate = self;
    
    NSString* path = [[NSString stringWithFormat:@"https://strava.com/oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code&scope=view_private write&approval_prompt=force",
                       client.clientID, @"runthetrack://localhost"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL* authUrl = [NSURL URLWithString:path];
    [stravaWebView loadRequest:[NSURLRequest requestWithURL:authUrl]];
    
    [self.view addSubview:stravaWebView];
    
//    //https://www.strava.com/oauth/authorize?response_type=code&redirect_uri=http://127.0.0.1&scope=view_private&approval_prompt=force&client_id=1401
//    
//    
//
//    
//    NSDictionary *queryParams = @{ @"client_id" : @"1401",
//                                   @"response_type" : @"code",
//                                   @"redirect_uri" : @"http://127.0.0.1"};
//    
//    [client authenticateUsingOAuthWithPath:@"https://www.strava.com/oauth/authorize"
//                                parameters:queryParams
//                                   success:^(AFOAuthCredential *credential) {
//                                       NSLog(@"Successfully received OAuth credentials %@", credential.accessToken);
//                                       [AFOAuthCredential storeCredential:credential
//                                                           withIdentifier:client.serviceProviderIdentifier];
//                                       
//                                       [self postToStrava:filePath andIdentifier:client.serviceProviderIdentifier];
//                                   
//                                   }
//                                   failure:^(NSError *error) {
//                                       NSLog(@"OAuth Error: %@", error);
//                                   }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"request url %@", request.URL);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
        NSLog(@"web started loading");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"web finshied loading");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Error %@",error.localizedDescription);
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"stravaCode"]) {
        
        [stravaWebView removeFromSuperview];
        
        NSDictionary *queryParams = @{ @"code" : appDelegate.stravaCode};
        
        NSURL *url = [NSURL URLWithString:@"https://www.strava.com/oauth/"];
        
        AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:url clientID:@"1401" secret:@"967b9297f6f1c9a0a8fe10a021cf211fa35b4d59"];
        
        [client authenticateUsingOAuthWithPath:@"token"
                                        parameters:queryParams
                                           success:^(AFOAuthCredential *credential) {
                                               NSLog(@"Successfully received OAuth credentials %@", credential.accessToken);
                                               [AFOAuthCredential storeCredential:credential
                                                                   withIdentifier:client.serviceProviderIdentifier];
        
                                               [self postToStravaWithIdentifier:client.serviceProviderIdentifier];
        
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"OAuth Error: %@", error);
                                           }];
        
    }
}

-(void)postToStravaWithIdentifier:(NSString *)stravaId
{

    NSURL *url = [NSURL URLWithString:@"http://www.strava.com"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
   // NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:stravaId];
    
    NSString *accessToken = credential.accessToken;
    
    NSDictionary *parameters = @{@"access_token": accessToken, @"activity_type" : @"ride",@"data_type" : @"fit", @"name" : @"Test", @"stationary" : @"1" };
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/api/v3/uploads" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath] name:@"file" fileName:@"TestStrava.gpx" mimeType:@"application/octet-stream"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"succss %@", responseObject);
        
        // Poll for success and show message
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Export Succesful"
                                                     description:@"Your run has been uploaded"
                                                            type:MessageBarMessageTypeInfo];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failure %@ \n\n %@", error, operation);
        
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
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
    //return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

- (NSString *)createGPX
{
    // gpx
    GPXRoot *gpx = [GPXRoot rootWithCreator:@"GPSLogger"];
    
    // gpx > trk
    GPXTrack *gpxTrack = [gpx newTrack];
    gpxTrack.name = self.runData.runtrackname;
    
    // gpx > trk > trkseg > trkpt

    NSMutableArray *points = [[self.runData.runDataLocations allObjects] mutableCopy];
    
    [points sortUsingComparator:^NSComparisonResult(id a, id b) {
        RunLocations *aRunLocation = (RunLocations *)a;
        RunLocations *bRunLocation = (RunLocations *)b;
        NSInteger firstInteger = [aRunLocation.locationIndex integerValue];
        NSInteger secondInteger = [bRunLocation.locationIndex integerValue];
        
        if (firstInteger > secondInteger)
            return NSOrderedAscending;
        if (firstInteger < secondInteger)
            return NSOrderedDescending;
        return [aRunLocation.locationIndex localizedCompare: bRunLocation.locationIndex];
    }];
    
    NSInteger numberOfSteps = points.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        RunLocations *runlocation = (RunLocations *)[points objectAtIndex:index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([runlocation.lattitude doubleValue], [runlocation.longitude doubleValue]);
        coordinates[index] = coordinate;
        
        GPXTrackPoint *gpxTrackPoint = [gpxTrack newTrackpointWithLatitude:runlocation.lattitude.floatValue longitude:runlocation.longitude.floatValue];
        gpxTrackPoint.elevation = 0;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MMM/yyyy HH:mm:ss.SS"];
        gpxTrackPoint.time =  [df dateFromString:runlocation.locationTimeStamp];
    }
    
    NSString *gpxString = gpx.gpx;
    
    // write gpx to file
    NSError *error;
    filePath = [self gpxFilePath];
    if (![gpxString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (error) {
            NSLog(@"error, %@", error);
        }
        
        return nil;
    }
    
    return filePath;
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
