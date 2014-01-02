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
#import "AppDelegate.h"
#import "RunSectors.h"

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
    [self zoomToPolyLine:mv polyLine:self.trackLine animated:YES];
}

-(void)zoomToPolyLine: (MKMapView*)map polyLine: (MKPolyline*)polyLine
             animated: (BOOL)animated
{
    MKPolygon* polygon =
    [MKPolygon polygonWithPoints:polyLine.points count:polyLine.pointCount];
    
    [map setRegion:MKCoordinateRegionForMapRect([polygon boundingMapRect])
          animated:animated];
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
    
    [lapSlider setThumbImage:[UIImage imageNamed:@"routes-man"] forState:UIControlStateNormal];
    
    runTime.text = [NSString stringWithFormat:@"Time : %@", self.runData.runtime];
    runLaps.text = [NSString stringWithFormat:@"Laps : %@",self.runData.runlaps];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"%.02f km", [self.runData.rundistance floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"Distance %.2f miles",[self.runData.rundistance floatValue] * 0.000621371192];
    }
    
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
    
    [self showSectorTimes];
}

-(void)showSectorTimes
{
    if([self.runData.runlaps integerValue] > 0)
    {
        runLapsArray = [[self.runData.runSectors allObjects] mutableCopy];
        [runLapsArray sortUsingComparator:^NSComparisonResult(id a, id b) {
            RunSectors *aRunSector = (RunSectors *)a;
            RunSectors *bRunSector = (RunSectors *)b;
            NSInteger firstInteger = [aRunSector.lapNumber integerValue];
            NSInteger secondInteger = [bRunSector.lapNumber integerValue];
            
            if (firstInteger > secondInteger)
                return NSOrderedDescending;
            if (firstInteger < secondInteger)
                return NSOrderedAscending;
            return [aRunSector.lapNumber localizedCompare: bRunSector.lapNumber];
        }];
        
        RunSectors *runSector = (RunSectors *)[runLapsArray objectAtIndex:0];
        lapNumerTime.text = [NSString stringWithFormat:@"Lap %@  Time %@", runSector.lapNumber, runSector.lapTime];

        sector1Time.text = [NSString stringWithFormat:@"Sector1 : %@", runSector.sector1Time];
        sector2Time.text = [NSString stringWithFormat:@"Sector2 : %@", runSector.sector2Time];
        sector3Time.text = [NSString stringWithFormat:@"Sector3 : %@", runSector.sector3Time];

        lapSlider.minimumValue = 1;
        lapSlider.maximumValue = [self.runData.runlaps integerValue]-1;
    }
    else
    {
        sector1Time.hidden = YES;
        sector2Time.hidden = YES;
        sector3Time.hidden = YES;
        lapSlider.hidden = YES;
        lapNumerTime.hidden = YES;
    }
}

-(IBAction)lapSliderChanged:(id)sender
{
    int sliderInt = roundf(lapSlider.value);
    RunSectors *runSector = (RunSectors *)[runLapsArray objectAtIndex:sliderInt];
    lapNumerTime.text = [NSString stringWithFormat:@"Lap %@  Time %@", runSector.lapNumber, runSector.lapTime];
    
    sector1Time.text = [NSString stringWithFormat:@"Sector1 : %@", runSector.sector1Time];
    sector2Time.text = [NSString stringWithFormat:@"Sector2 : %@", runSector.sector2Time];
    sector3Time.text = [NSString stringWithFormat:@"Sector3 : %@", runSector.sector3Time];
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
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ %@", self.navigationItem.title, runTime.text, runDistance.text]];
    
    UIGraphicsBeginImageContext(mv.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
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
