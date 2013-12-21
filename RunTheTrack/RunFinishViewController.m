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
    
    self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    runTime.text = [NSString stringWithFormat:@"%@",[self.trackInfo objectForKey:@"runTime"]];
    runLaps.text = [NSString stringWithFormat:@"Laps %@",[self.trackInfo objectForKey:@"runLaps"]];
    runDistance.text = [NSString stringWithFormat:@"Distance %@ miles",[self.trackInfo objectForKey:@"runDistance"]];
    paceLabel.text = [NSString stringWithFormat:@"%@ mph",@"3.1"];
    trackMapImage.image = [UIImage imageNamed:[self.trackInfo objectForKey:@"mapimage"]];
    trackName.text = [self.trackInfo objectForKey:@"Race"];
    [self addRouteToMap];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
}

#pragma mark choose track
-(void)setTrackInfo:(NSMutableDictionary *)trackInfoDict
{
    _trackInfo = trackInfoDict;
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
            //NSLog([NSString stringWithFormat:@"Real %.2f miles", totalDistance * 0.000621371192]);
        }
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
    [runData setRundate:[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                              dateStyle:NSDateFormatterMediumStyle
                                                                              timeStyle:NSDateFormatterShortStyle]];
    
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
    
//    if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"LongestDistance"]  withManagedObjectContext:self.managedObjectContext])
//    {
//        // fastest lap
//        [newRunAchievements setObject:@"New Fastest Lap" forKey:@"LongestDistance"];
//        [[MessageBarManager sharedInstance] showMessageWithTitle:@"New Fastest Lap"
//                                                     description:[NSString stringWithFormat:@"Timed at : %@", [dateFormatter stringFromDate:timerDate]]
//                                                            type:MessageBarMessageTypeInfo];
//    }
//    
//    if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FastestLap"]  withManagedObjectContext:self.managedObjectContext])
//    {
//        // fastest lap
//        [newRunAchievements setObject:@"New Fastest Lap" forKey:@"FastestLap"];
//        [[MessageBarManager sharedInstance] showMessageWithTitle:@"New Fastest Lap"
//                                                     description:[NSString stringWithFormat:@"Timed at : %@", [dateFormatter stringFromDate:timerDate]]
//                                                            type:MessageBarMessageTypeInfo];
//    }
//    
//    if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FastestLap"]  withManagedObjectContext:self.managedObjectContext])
//    {
//        // fastest lap
//        [newRunAchievements setObject:@"New Fastest Lap" forKey:@"FastestLap"];
//        [[MessageBarManager sharedInstance] showMessageWithTitle:@"New Fastest Lap"
//                                                     description:[NSString stringWithFormat:@"Timed at : %@", [dateFormatter stringFromDate:timerDate]]
//                                                            type:MessageBarMessageTypeInfo];
//    }
    
    //Add Achivement
    RunAchievement *runAch = [NSEntityDescription insertNewObjectForEntityForName:@"RunAchievement" inManagedObjectContext:self.managedObjectContext];
    [runAch setRunId:runData.runid];
    [runAch setTrackname:runData.runtrackname];
    [runAch setAchievementTrigger:@"Completed Circuit"];
    [runAch setAchievementText:[NSString stringWithFormat:@"Completed Circuit %@ for the 1st time", runData.runtrackname]];
    [runData addRunAchievementObject:runAch];
    
    [CoreDataHelper saveManagedObjectContext:self.managedObjectContext];
    
    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Run Saved"
                                                 description:@"Well done, check out your timings now."
                                                        type:MessageBarMessageTypeSuccess];
}

#pragma social sharing 

-(IBAction)showActivityView:(id)sender
{
    NSString *textToShare = [NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ Distance %@", trackName.text, runTime.text, runDistance.text];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = mv.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = mv.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        // get the image associated with the snapshot
        
        UIImage *image = snapshot.image;
        
        // Get the size of the final image
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        // ok, let's start to create our final image
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // now, let's iterate through the annotations and draw them, too
        
        for (id<MKAnnotation>annotation in mv.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                
                [pinImage drawAtPoint:point];
            }
        }
        
        // grab the final image
        mapImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSArray *itemsToShare = @[textToShare, mapImage];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeMail];
        [self presentViewController:activityVC animated:YES completion:nil];
    }];
}


-(IBAction)shareOnFacebook:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Share on facebook"
                                                     description:@"Creating the post now"
                                                            type:MessageBarMessageTypeInfo];
        [self composePost:SLServiceTypeFacebook];
    }
}
    
-(IBAction)shareOnTwitter:(id)sender
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
    [composeSheet setInitialText:[NSString stringWithFormat:@"Just comepleted a run round the %@ GP track. Time %@ Distance %@", trackName.text, runTime.text, runDistance.text]];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = mv.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = mv.frame.size;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        // get the image associated with the snapshot
        
        UIImage *image = snapshot.image;
        
        // Get the size of the final image
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        // ok, let's start to create our final image
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // now, let's iterate through the annotations and draw them, too
        
        for (id<MKAnnotation>annotation in mv.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                
                [pinImage drawAtPoint:point];
            }
        }
        
        // grab the final image
        mapImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [composeSheet addImage:mapImage];
        [self presentViewController:composeSheet animated:YES completion:nil];
        
    }];
}

@end
