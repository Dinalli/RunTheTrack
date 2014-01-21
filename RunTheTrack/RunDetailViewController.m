//
//  RunDetailViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunDetailViewController.h"
#import "CoreDataHelper.h"
#import <Social/Social.h>
#import "AppDelegate.h"
#import "RunSectors.h"
#import "StartFinishAnnotation.h"
#import "Sector1Annotaion.h"
#import "Sector2Annotation.h"

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
    if(self.trackLine.pointCount > 0)
    {
        [self zoomToPolyLine:mv polyLine:self.trackLine animated:YES];
    }
    else
    {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.0200;
        span.longitudeDelta = 0.0200;
        region.span = span;
        region.center.latitude = coordinates[numberOfSteps-1].latitude;
        region.center.longitude = coordinates[numberOfSteps-1].longitude;
        [mv setRegion:region animated:YES];
    }
    
    
    // Add points to map for annotations
    RunLocations *startRunLocation = (RunLocations *)[points objectAtIndex:0];
    RunLocations *endRunLocation = (RunLocations *)[points objectAtIndex:points.count-1];
    CLLocationCoordinate2D startCoordinate = CLLocationCoordinate2DMake([startRunLocation.lattitude doubleValue], [startRunLocation.longitude doubleValue]);
    CLLocationCoordinate2D endCoordinate = CLLocationCoordinate2DMake([endRunLocation.lattitude doubleValue], [endRunLocation.longitude doubleValue]);
    
    StartFinishAnnotation *startAnno = [[StartFinishAnnotation alloc] init];
    startAnno.coordinate = startCoordinate;
    startAnno.title = @"Finish";
    [mv addAnnotation:startAnno];
    
    
    StartFinishAnnotation *finishAnno = [[StartFinishAnnotation alloc] init];
    finishAnno.coordinate = endCoordinate;
    finishAnno.title = @"Start";
    [mv addAnnotation:finishAnno];
    
    [self showSectorTimes];
    
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
    
    [self.navigationController setNavigationBarHidden:YES];
    
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

    [CommonUtils shadowAndRoundView:detailsView];
    [CommonUtils addMotionEffectToView:detailsView];
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
        
        for(RunSectors *rSector in runLapsArray)
        {
            CLLocationCoordinate2D lapCordinate =  CLLocationCoordinate2DMake([rSector.lapLat doubleValue], [rSector.lapLong doubleValue]);

            StartFinishAnnotation *finishAnno = [[StartFinishAnnotation alloc] init];
            finishAnno.coordinate = lapCordinate;
            finishAnno.title = [NSString stringWithFormat:@"Lap %@ time %@",rSector.lapNumber, rSector.lapTime];
            [mv addAnnotation:finishAnno];

            CLLocationCoordinate2D sect1Cordinate =  CLLocationCoordinate2DMake([rSector.sec1Lat doubleValue], [rSector.sec1Long doubleValue]);
            
            StartFinishAnnotation *sector1Anno = [[StartFinishAnnotation alloc] init];
            sector1Anno.coordinate = sect1Cordinate;
            sector1Anno.title = [NSString stringWithFormat:@"Sector 1 %@",rSector.sector1Time];
            [mv addAnnotation:sector1Anno];
            
            CLLocationCoordinate2D sect2Cordinate =  CLLocationCoordinate2DMake([rSector.sec2Lat doubleValue], [rSector.sec2Long doubleValue]);
            
            StartFinishAnnotation *sector2Anno = [[StartFinishAnnotation alloc] init];
            sector2Anno.coordinate = sect2Cordinate;
            sector2Anno.title = [NSString stringWithFormat:@"Sector 2 %@",rSector.sector2Time];
            [mv addAnnotation:sector2Anno];
        }
    }
}

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"RunSectorsSegue"]) {
//        RunSectorsViewController *rsvc = segue.destinationViewController;
//        [rsvc setRunData:self.runData];
//    }
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
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. %@ %@ %@", self.navigationItem.title, runTime.text, runDistance.text, runLaps.text]];
    
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
