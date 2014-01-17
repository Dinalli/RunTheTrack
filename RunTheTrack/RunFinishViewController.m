//
//  RunFinishViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 27/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RunFinishViewController.h"
#import "CoreDataHelper.h"
#import "RunData.h"
#import "RunLocations.h"
#import "RunSectors.h"
#import "RunAchievement.h"
#import "RunAltitude.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"
#import <Social/Social.h>

@interface RunFinishViewController ()

@end

@implementation RunFinishViewController

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
    
    [self.navigationItem.backBarButtonItem setTitle:@"Run"];
    [self.navigationItem setTitle:[self.trackInfo objectForKey:@"Race"]];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    runTime.text = [NSString stringWithFormat:@"%@",[self.trackInfo objectForKey:@"runTime"]];
    NSString *strTimeLong = [self.trackInfo objectForKey:@"timeLabel"];
    unsigned long timeLong = strtoul([strTimeLong UTF8String], NULL, 0);
    [self.timeLabel setSavedValue:timeLong];
    [self.timeLabel updateApperance];
    runLaps.text = [NSString stringWithFormat:@"Laps %@",[self.trackInfo objectForKey:@"runLaps"]];
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"Distance %.2f km",[[self.trackInfo objectForKey:@"runDistance"] floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"Distance %.2f miles",[[self.trackInfo objectForKey:@"runDistance"] floatValue] * 0.000621371192];
    }
    
    paceLabel.text = [NSString stringWithFormat:@"%@ mph",@"3.1"];
    trackMapImage.image = [UIImage imageNamed:[self.trackInfo objectForKey:@"mapimage"]];
    trackName.text = [self.trackInfo objectForKey:@"Race"];
    
    if(appDelegate.useMotion)
    {
        self.trackPointArray = [[NSMutableArray alloc] init];
        [self addTrackPoints];
    }
    else
    {
        [self addRouteToMap];
    }
    
    [self customiseAppearance];
}

- (void)customiseAppearance {
    [self.timeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:55]];
    [self.timeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:55]];
    
    // The font property of the label is used as the font for H,M,S and MS
    [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];
    
    // Default label properties
    self.timeLabel.textColor = [UIColor purpleColor];
    
    // After making any changes we need to call update appearance
    [self.timeLabel updateApperance];
}

#pragma mark choose track
-(void)setTrackInfo:(NSMutableDictionary *)trackInfoDict
{
    _trackInfo = trackInfoDict;
}

-(void)addTrackPoints
{
    [mv removeAnnotations:mv.annotations];
    CLLocationCoordinate2D poi;
    
    NSArray *sectorArray = [_trackInfo objectForKey:@"trackpoints"];
    
    for(NSString *coordPoint in sectorArray)
    {
        if([self.trackPointArray count] > 0)
        {
            NSArray *latlong = [coordPoint componentsSeparatedByString:@","];
            NSString *lat = [latlong objectAtIndex:0];
            NSString *lng = [latlong objectAtIndex:1];
            
            NSArray *oldlatlong = [[self.trackPointArray lastObject] componentsSeparatedByString:@","];
            NSString *oldlat = [oldlatlong objectAtIndex:0];
            NSString *oldlng = [oldlatlong objectAtIndex:1];
            
            CLLocationCoordinate2D oldpoi = CLLocationCoordinate2DMake([oldlat doubleValue], [oldlng doubleValue]);
            poi = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            CLLocationCoordinate2D coordinates[2];
            coordinates[0] = oldpoi;
            coordinates[1] = poi;
            
            [self.trackPointArray addObject:coordPoint];
            
            self.trackLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
            [mv addOverlay:self.trackLine];
            
            MKCoordinateRegion region;
            MKCoordinateSpan span;
            span.latitudeDelta = 0.0030;
            span.longitudeDelta = 0.0030;
            region.span = span;
            region.center.latitude = [lat doubleValue];
            region.center.longitude = [lng doubleValue];
            [mv setRegion:region animated:YES];
        }
        else
        {
            [self.trackPointArray addObject:coordPoint];
        }
    }
}


#pragma mark draw map route

-(void)addRouteToMap
{
    // Get Run Locations
    NSArray *points = [_trackInfo objectForKey:@"runPointArray"];    
    NSInteger numberOfSteps = points.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [points objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
        
        if(index > 0)
        {
            CLLocation *lastLocation = [points objectAtIndex:index-1];
            totalDistance = totalDistance + [location distanceFromLocation:lastLocation];
        }
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView* overlayView = nil;
    self.trackLineView = [[MKPolylineView alloc] initWithPolyline:[self trackLine]];
    
    [[self trackLineView] setFillColor:[UIColor colorWithRed:167/255.0f green:210/255.0f blue:244/255.0f alpha:1.0]];
    [[self trackLineView] setStrokeColor:[UIColor colorWithRed:106/255.0f green:151/255.0f blue:232/255.0f alpha:1.0]];
    
    [[self trackLineView] setLineWidth:5.0];
    [[self trackLineView] setLineCap:kCGLineCapRound];
    overlayView = [self trackLineView];
    return overlayView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self saveRun];
}

#pragma mark Save Run

-(void)saveRun
{
    RunData *runData = [NSEntityDescription insertNewObjectForEntityForName:@"RunData" inManagedObjectContext:self.managedObjectContext];
    NSManagedObjectID *moID = [runData objectID];
    
    [runData setRunid:[[moID URIRepresentation] absoluteString]];
    [runData setRuntrackname:[self.trackInfo valueForKey:@"Race"]];
    [runData setRuntime:[self.trackInfo valueForKey:@"runTime"]];
    [runData setRunlaps:[self.trackInfo valueForKey:@"runLaps"]];
    [runData setRundistance:[self.trackInfo valueForKey:@"runDistance"]];
    [runData setRunPace:@"0"];
    [runData setRundate:[CommonUtils formattedStringFromDate:[NSDate date]]];
    
    NSArray *points = [_trackInfo objectForKey:@"runPointArray"];
    NSInteger numberOfSteps = points.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [points objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        
        RunLocations *runLocation = [NSEntityDescription insertNewObjectForEntityForName:@"RunLocations" inManagedObjectContext:self.managedObjectContext];
        [runLocation setRunid:runData.runid];
        [runLocation setLocationIndex:[NSString stringWithFormat:@"%d",(int)index]];
        [runLocation setLattitude:[NSString stringWithFormat:@"%f",location.coordinate.latitude]];
        [runLocation setLongitude:[NSString stringWithFormat:@"%f",location.coordinate.longitude]];
        [runLocation setLocationTimeStamp:[CommonUtils formattedStringFromDate:location.timestamp]];
        
        [runData addRunDataLocationsObject:runLocation];
    }
    
    // Add Sectors and Laps to Save
    
    NSDictionary *runLapsDict = (NSDictionary *)[_trackInfo objectForKey:@"runLapsInfo"];
    if(runLapsDict.count > 0)
    {
        NSArray *lapKeys = [runLapsDict allKeys];
        
        for (NSString *lapNumberKey in lapKeys)
        {
            NSDictionary *runLap = [runLapsDict objectForKey:lapNumberKey];
            RunSectors *runSectors = [NSEntityDescription insertNewObjectForEntityForName:@"RunSectors" inManagedObjectContext:self.managedObjectContext];
            
            [runSectors setRunId:runData.runid];
            [runSectors setSector1Time:[runLap objectForKey:@"1"]];
            [runSectors setSector2Time:[runLap objectForKey:@"2"]];
            [runSectors setSector3Time:[runLap objectForKey:@"3"]];
            [runSectors setLapTime:[runLap objectForKey:@"Lap"]];
            [runSectors setLapNumber:lapNumberKey];
            
            [runData addRunSectorsObject:runSectors];
        }
    }
        
    NSDictionary *runAchivements = (NSDictionary *)[_trackInfo objectForKey:@"runAchivementsInfo"];
    if(runAchivements.count > 0)
    {
        NSArray *achKeys = [runAchivements allKeys];
        
        for (NSString *achivementKey in achKeys)
        {
            //Add Achivement
            RunAchievement *runAch = [NSEntityDescription insertNewObjectForEntityForName:@"RunAchievement" inManagedObjectContext:self.managedObjectContext];
            [runAch setRunId:runData.runid];
            [runAch setTrackname:runData.runtrackname];
            [runAch setAchievementTrigger:achivementKey];
            [runAch setAchievementText:[runAchivements objectForKey:achivementKey]];
            [runData addRunAchievementObject:runAch];
        }
    }
    
    NSArray *runAlitiudes = (NSArray *)[_trackInfo objectForKey:@"runAltitude"];
    if(runAlitiudes.count > 0)
    {
        for (NSDictionary *runAltDict in runAlitiudes)
        {
            //Add Achivement
            RunAltitude *runAlt = [NSEntityDescription insertNewObjectForEntityForName:@"RunAltitude" inManagedObjectContext:self.managedObjectContext];
            [runAlt setRunid:runData.runid];
            [runAlt setAltitudeTimeStamp:[runAltDict objectForKey:@"time"]];
            [runAlt setAltitude:[runAltDict objectForKey:@"altitude"]];
            [runData addRunAltitudesObject:runAlt];
        }
    }
    
    [CoreDataHelper saveManagedObjectContext:self.managedObjectContext];
    
    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Run Saved"
                                                 description:@"Well done, check out your timings now."
                                                        type:MessageBarMessageTypeSuccess];
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
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ %@ %@", self.navigationItem.title, [self.timeLabel getValueString], runDistance.text, runLaps.text]];
    
    UIGraphicsBeginImageContext(mv.frame.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [mv.layer renderInContext:currentContext];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [composeSheet addImage:screenshot];
    [self presentViewController:composeSheet animated:YES completion:nil];
}

@end
