//
//  RunDetailViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunDetailViewController.h"
#import "CoreDataHelper.h"
#import "RunSectorsViewController.h"
#import <Social/Social.h>

@interface RunDetailViewController ()

@end

@implementation RunDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)addRouteToMap
{
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
    }
    
    self.trackLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [mv addOverlay:self.trackLine level:MKOverlayLevelAboveLabels];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0200;
    span.longitudeDelta = 0.0200;
    region.span = span;
    region.center.latitude = coordinates[numberOfSteps-1].latitude;
    region.center.longitude = coordinates[numberOfSteps-1].longitude;
    [mv setRegion:region animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:self.trackLine];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 7;
    return lineView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    runTime.text = [NSString stringWithFormat:@"Time : %@", self.runData.runtime];
    runLaps.text = [NSString stringWithFormat:@"Laps : %@",self.runData.runlaps];
    runDistance.text = [NSString stringWithFormat:@"Distance : %@ miles",self.runData.rundistance];
    runDate.text = [NSString stringWithFormat:@"Date : %@",self.runData.rundate];
    self.navigationItem.title = self.runData.runtrackname;
    
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    NSArray *tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    for (NSDictionary *trackInfo in tracksArray) {
        if([[trackInfo objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            trackMapImage.image = [UIImage imageNamed:[trackInfo objectForKey:@"mapimage"]];
        }
    }    
    [self addRouteToMap];
}

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunSectorsSegue"]) {
        RunSectorsViewController *rsvc = segue.destinationViewController;
        [rsvc setRunData:self.runData];
    }
}
    
#pragma social sharing

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
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ Distance %@", self.navigationItem.title, runTime.text, runDistance.text]];
    
    UIGraphicsBeginImageContext(mv.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(currentContext, 0, mv.frame.size.height);
    // passing negative values to flip the image
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    [mv.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
