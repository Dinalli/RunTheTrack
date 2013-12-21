//
//  StartViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 16/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "StartViewController.h"
#import "RunFinishViewController.h"
#import "MKRunnerAnnotation.h"
#import "StartFinishAnnotation.h"
#import "Sector1Annotaion.h"
#import "Sector2Annotation.h"
#import "UIImage+ImageEffects.h"
#import "CoreDataHelper.h"
#import "RunAchievement.h"

typedef NS_ENUM(NSInteger, kTTCounter){
    kTTCounterRunning = 0,
    kTTCounterStopped,
    kTTCounterReset,
    kTTCounterEnded
};

enum TimerState : NSUInteger {
    timerStopped = 1,
    timerStarted = 2,
    timerPaused = 3,
    timerFinished = 4
};

@interface StartViewController ()

@property (strong, nonatomic) IBOutlet TTCounterLabel *timeLabel;
@property enum TimerState timerState;

@end

@implementation StartViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self customiseAppearance];
    
	// Do any additional setup after loading the view.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //Listen to notification of track playing changing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicTrackChanged) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    self.timerState = timerStopped;
    lapCounter = 0;
    
    [self.navigationItem setTitle:[self.trackInfo objectForKey:@"Race"]];
    lapsLabel.text = [NSString stringWithFormat:@"0/%@",[self.trackInfo objectForKey:@"Laps"]];
    
    [self startTracking];
    [self addTrackPoints];
    
    currentAchievements = [CoreDataHelper searchObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@", [self.trackInfo objectForKey:@"Race"]] withSortKey:nil sortAscending:YES withManagedObjectContext:self.managedObjectContext];
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

#pragma mark start stop run
- (IBAction)startStop:(id)sender
{
    if(self.timerState == timerStopped)
    {
        // Start the timer
        [self playSound:@"beep-8" :@"mp3"];
        startDate = [NSDate date];
        lastLapDate = startDate;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
        self.timerState = timerStarted;
        [self.timeLabel start];
        btnFinish.hidden = YES;
    }
    else if(self.timerState == timerStarted)
    {
        [self.timeLabel stop];
        [self pauseTimer:timer];
        [startBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        self.timerState = timerStopped;
        btnFinish.hidden = NO;
    }
//    else if(self.timerState == timerPaused)
//    {
//        [self.timeLabel start];
//        [self resumeTimer:timer];
//        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
//        self.timerState = timerStarted;
//    }
}

- (void)timerTick:(NSTimer *)timer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    timeInterval += secondsAlreadyRun;
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    totalRunTime = [dateFormatter stringFromDate:timerDate];
    [self.timeLabel setCurrentValue:timeInterval];
}

-(void) pauseTimer:(NSTimer *)pauseTimer
{
    secondsAlreadyRun += [[NSDate date] timeIntervalSinceDate:startDate];
    [timer invalidate];
}

-(void) resumeTimer:(NSTimer *)resumeTimer
{
    startDate = [NSDate date];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

#pragma mark choose track
-(void)setTrackInfo:(NSMutableDictionary *)trackInfoDict
{
    _trackInfo = trackInfoDict;
}

#pragma mark media picker

- (IBAction)showMediaPicker:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection: mediaItemCollection];
        [musicPlayer play];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark music player   
-(void)musicTrackChanged
{
//    currentTrack.text =  [NSString stringWithFormat:@"%@ - %@",[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist],[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle]];
}

#pragma mark Map view

-(void)startTracking
{
    self.trackPointArray = [[NSMutableArray alloc] init];
    self.runPointArray  = [[NSMutableArray alloc] init];
    [self setTimeDuration:0];
    
    if(appDelegate.useMotion)
    {
        [self enableCoreMotion];
    }
    else
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 1.0; // setting this to 5.0 as it seems to be best and stop jitters.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startUpdatingLocation];
    }
}

-(void)addTrackPoints
{
    [mv removeAnnotations:mv.annotations];
    CLLocationCoordinate2D poi;
    CLLocationDistance totalDistance;
    CLLocationDistance sectorCalcDistance;

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
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalDistance = totalDistance + [lastLocation distanceFromLocation:nextLocation];
            
        }
        else
        {
            [self.trackPointArray addObject:coordPoint];
        }
    }
    
    // add the sector points for 1, 2
    // divide the total track distance by 3
    sectorCalcDistance = totalDistance / 3;
    totalDistance = 0;
    bool sector1Set = FALSE;
    
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
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalDistance = totalDistance + [lastLocation distanceFromLocation:nextLocation];
            
            if(totalDistance > (sectorCalcDistance))
            {
                if(!sector1Set)
                {
                    sector1EndPoint = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
                    sector1Set = TRUE;
                }
            }
            
            if(totalDistance > (sectorCalcDistance * 2))
            {
                sector2EndPoint = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
                break;
            }
        }
    }
    
    MKRunnerAnnotation *runner = [[MKRunnerAnnotation alloc] init];
    runner.coordinate = poi;
    runner.title = @"Runner";
    [mv addAnnotation:runner];
    
    // Add start finish indicator
    NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
    StartFinishAnnotation *startfinish = [[StartFinishAnnotation alloc] init];
    CLLocationCoordinate2D startFinishPoi = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Lat"] doubleValue], [[startFinishDict objectForKey:@"Long"] doubleValue]);
    startfinish.coordinate = startFinishPoi;
    startfinish.title = @"Start Finish";
    [mv addAnnotation:startfinish];

    Sector1Annotaion *sector1Ann = [[Sector1Annotaion alloc] init];
    sector1Ann.coordinate = CLLocationCoordinate2DMake(sector1EndPoint.coordinate.latitude, sector1EndPoint.coordinate.longitude);
    sector1Ann.title = @"Sector1";
    [mv addAnnotation:sector1Ann];
    
    Sector2Annotation *sector2Ann = [[Sector2Annotation alloc] init];
    sector2Ann.coordinate = sector2EndPoint.coordinate;
    sector2Ann.title = @"Sector2";
    [mv addAnnotation:sector2Ann];
    
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0100;
    span.longitudeDelta = 0.0100;
    region.span = span;
    region.center.latitude = poi.latitude;
    region.center.longitude = poi.longitude;
    [mv setRegion:region animated:YES];
}

#pragma mark MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    // handle our three custom annotations
    //
    if ([annotation isKindOfClass:[MKRunnerAnnotation class]])
    {
        static NSString *RunnerAnnotationIdentifier = @"runnerID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:RunnerAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:RunnerAnnotationIdentifier];
            UIImage *flagImage = [UIImage imageNamed:@"runnerDot.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else if ([annotation isKindOfClass:[StartFinishAnnotation class]])
    {
        static NSString *SFAnnotationIdentifier = @"StartFinishID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:SFAnnotationIdentifier];
            
            UIImage *flagImage = [UIImage imageNamed:@"cheq.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } else if ([annotation isKindOfClass:[Sector1Annotaion class]])
    {
        static NSString *sector1ID = @"Sector1ID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:sector1ID];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:sector1ID];
            UIImage *flagImage = [UIImage imageNamed:@"sector1.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } else if ([annotation isKindOfClass:[Sector2Annotation class]])
    {
        static NSString *sector2ID = @"Sector2ID";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:sector2ID];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:sector2ID];
            UIImage *flagImage = [UIImage imageNamed:@"sector2.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

#pragma mark CoreMotion 

-(void)enableCoreMotion
{
    if([CMMotionActivityManager isActivityAvailable])
    {
        if(cmActivityMgr == nil) cmActivityMgr = [[CMMotionActivityManager alloc] init];
        
        [cmActivityMgr startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            
            if(activity.walking)
            {
                distanceLabel.text = @"Walking";
            }else if (activity.running)
            {
                distanceLabel.text = @"Running";
            }
        }];
    }
    
    if([CMStepCounter isStepCountingAvailable])
    {
        if(cmStepCounter == nil) cmStepCounter = [[CMStepCounter alloc] init];
        
//        [cmStepCounter queryStepCountStartingFrom:[NSDate dateWithTimeIntervalSinceNow:-7*24*60*60] to:[NSDate date] toQueue:[NSOperationQueue mainQueue] withHandler:^(NSInteger numberOfSteps, NSError *error) {
//            
//            todaysStepCounter.text = [NSString stringWithFormat:@"%ld steps for week", numberOfSteps];
//        }];
        
        [cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            
            if(self.timerState == timerStarted)
            {
                CGFloat distance = numberOfSteps * 2.5; // Running
                [self moveAnnotaionWithDistance:distance];
            }
        }];
    }
}

-(void)moveAnnotaionWithDistance:(CGFloat)distance
{
    for (id<MKAnnotation> ann in mv.annotations)
    {
        if ([ann.title isEqualToString:@"Runner"])
        {
            NSArray *lastlatlong = [[self.trackPointArray objectAtIndex:runIndex] componentsSeparatedByString:@","];
            NSString *lastlat = [lastlatlong objectAtIndex:0];
            NSString *lastlng = [lastlatlong objectAtIndex:1];
            
            int nextRunIndex;
            if(runIndex == self.trackPointArray.count-1)
            {
                nextRunIndex = 0;
            }
            else{
                nextRunIndex = runIndex+1;
            }
            
            NSArray *nextlatlong = [[self.trackPointArray objectAtIndex:nextRunIndex] componentsSeparatedByString:@","];
            NSString *nextlat = [nextlatlong objectAtIndex:0];
            NSString *nextlng = [nextlatlong objectAtIndex:1];
            
            CLLocation *startPoint = [[CLLocation alloc] initWithLatitude:[lastlat doubleValue] longitude:[lastlng doubleValue]];
            CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:[nextlat doubleValue] longitude:[nextlng doubleValue]];
            CLLocationDistance polyDistance = [startPoint distanceFromLocation:endPoint];
            
            if(distance > 0 && distance < polyDistance)
            {
                // move the annotation correct distance
                CLLocationCoordinate2D lastpoi = CLLocationCoordinate2DMake([lastlat doubleValue], [lastlng doubleValue]);
                CLLocationCoordinate2D nextpoi = CLLocationCoordinate2DMake([nextlat doubleValue], [nextlng doubleValue]);
                
                double latitudeModifier;    // Distance to add/subtract to each latitude point
                double longitudeModifier;   // Distance to add/subtract to each longitude point
                
                int numberOfPoints = 250;   // The number of points you want between the two points
                
                CLLocationCoordinate2D newPoint;
                // Determine the distance between the lats and divide by numberOfPoints
                latitudeModifier = (nextpoi.latitude - lastpoi.latitude) / numberOfPoints;
                // Same with lons
                longitudeModifier = (nextpoi.longitude - lastpoi.longitude) / numberOfPoints;
                
                // Loop through the points
                for (int i = 0; i < numberOfPoints; i++)
                {
                    
                    newPoint.latitude = lastpoi.latitude + (latitudeModifier * i);
                    newPoint.longitude = lastpoi.longitude + (longitudeModifier * i);
                    MKCoordinateRegion region;
                    MKCoordinateSpan span;
                    span.latitudeDelta = 0.0150;
                    span.longitudeDelta = 0.0150;
                    region.span = span;
                    region.center.latitude = newPoint.latitude;
                    region.center.longitude = newPoint.longitude;
                    [mv setRegion:region animated:YES];
                    ann.coordinate = newPoint;
                    
                    CLLocation *pointLoc = [[CLLocation alloc] initWithLatitude:newPoint.latitude longitude:newPoint.longitude];
                    if([startPoint distanceFromLocation:pointLoc] > distance)
                    {
                        //NSLog(@"Point Exit Distance %f", [startPoint distanceFromLocation:pointLoc]);
                        totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:pointLoc];
                        // eject at the point of the distance we need and set the old location to this point
                        [self.trackPointArray insertObject:[NSString stringWithFormat:@"%f,%f", pointLoc.coordinate.latitude, pointLoc.coordinate.longitude] atIndex:nextRunIndex];
                        break;
                    }
                    
                    if(endPoint == sector1EndPoint) sector1Time = lapTime.text;
                    if(endPoint == sector2EndPoint) sector2Time = lapTime.text;
                }
            }
            else // lets just move to the next point then
            {
                MKCoordinateRegion region;
                MKCoordinateSpan span;
                span.latitudeDelta = 0.0150;
                span.longitudeDelta = 0.0150;
                region.span = span;
                region.center.latitude = endPoint.coordinate.latitude;
                region.center.longitude = endPoint.coordinate.longitude;
                [mv setRegion:region animated:YES];
                ann.coordinate = endPoint.coordinate;
                
                totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:endPoint];
                if(endPoint == sector1EndPoint)
                {
                    sector1Time = lapTime.text;
                }
                if(endPoint == sector2EndPoint) {
                    sector2Time = lapTime.text;
                }
                
            }
            
            distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalPointsDistance * 0.000621371192];
            runIndex++;
            
            if(runIndex == self.trackPointArray.count)
            {
                //NSLog([NSString stringWithFormat:@"Lap Distance %.2f miles", totalPointsDistance * 0.000621371192]);
                //End of lap
                runIndex = 0;
                lapCounter++;
                lapsLabel.text = [NSString stringWithFormat:@"%d Laps", (int)lapCounter];
                [self playSound:@"beep-8" :@"mp3"];
                
                sector1Time = lapTime.text;
                sector2Time = lapTime.text;
                sector3Time = lapTime.text;
                
                // Save Sectors and Lap Times
                NSDictionary *runLap = @{@"1": sector1Time,
                                         @"2": sector2Time,
                                         @"3": sector3Time,
                                         @"Lap": lapTime.text};
                
                if(runLaps == nil) runLaps = [[NSMutableDictionary alloc] init];
                [runLaps setObject:runLap forKey:[NSString stringWithFormat:@"%d",(int)lapCounter]];
                
                // Convert to Date
                NSDate *currentDate = [NSDate date];
                NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:lastLapDate];
                //timeInterval += secondsAlreadyRun;
                NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"mm:ss.SS"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
                lapTime.text = [dateFormatter stringFromDate:timerDate];
                lastLapDate = [NSDate date];
                
                if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FastestLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
                {
                    // fastest lap
                    [newRunAchievements setObject:@"New Fastest Lap" forKey:@"FastestLap"];
                    [[MessageBarManager sharedInstance] showMessageWithTitle:@"New Fastest Lap"
                                                                 description:[NSString stringWithFormat:@"Timed at : %@", [dateFormatter stringFromDate:timerDate]]
                                                                        type:MessageBarMessageTypeInfo];
                }
                
                //Check any achivements
                [self checkAchivementsOnLapFinish];
            }
            
        } // end if Runner
        
    } // end Annotation Loop
}

#pragma mark CLLocationManager Delegate

#pragma mark - MapKit

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(self.timerState == timerStarted)
    {
        CLLocation *newLocation = [locations lastObject];
        CLLocation *oldLocation = [self.runPointArray lastObject];
        CLLocationDistance distance;
        
        //Always add the real location to array so we can show the real route later on
        [self.runPointArray addObject:newLocation];
        
        // No need to do anything if old location is not set
        if(oldLocation != nil)
        {
            distance = [newLocation distanceFromLocation:oldLocation];
            
            [self moveAnnotaionWithDistance:distance];
            // Move to a suitable spot on the track
//            for (id<MKAnnotation> ann in mv.annotations)
//            {
//                if ([ann.title isEqualToString:@"Runner"])
//                {
//                    NSArray *lastlatlong = [[self.trackPointArray objectAtIndex:runIndex] componentsSeparatedByString:@","];
//                    NSString *lastlat = [lastlatlong objectAtIndex:0];
//                    NSString *lastlng = [lastlatlong objectAtIndex:1];
//                    
//                    int nextRunIndex;
//                    if(runIndex == self.trackPointArray.count-1)
//                    {
//                        nextRunIndex = 0;
//                    }
//                    else{
//                        nextRunIndex = runIndex+1;
//                    }
//                    
//                    NSArray *nextlatlong = [[self.trackPointArray objectAtIndex:nextRunIndex] componentsSeparatedByString:@","];
//                    NSString *nextlat = [nextlatlong objectAtIndex:0];
//                    NSString *nextlng = [nextlatlong objectAtIndex:1];
//                    
//                    CLLocation *startPoint = [[CLLocation alloc] initWithLatitude:[lastlat doubleValue] longitude:[lastlng doubleValue]];
//                    CLLocation *endPoint = [[CLLocation alloc] initWithLatitude:[nextlat doubleValue] longitude:[nextlng doubleValue]];
//                    CLLocationDistance polyDistance = [startPoint distanceFromLocation:endPoint];
//                    
//                    if(distance > 0 && distance < polyDistance)
//                    {
//                        // move the annotation correct distance
//                        CLLocationCoordinate2D lastpoi = CLLocationCoordinate2DMake([lastlat doubleValue], [lastlng doubleValue]);
//                        CLLocationCoordinate2D nextpoi = CLLocationCoordinate2DMake([nextlat doubleValue], [nextlng doubleValue]);
//                        
//                        double latitudeModifier;    // Distance to add/subtract to each latitude point
//                        double longitudeModifier;   // Distance to add/subtract to each longitude point
//                        
//                        int numberOfPoints = 250;   // The number of points you want between the two points
//                        
//                        CLLocationCoordinate2D newPoint;
//                        // Determine the distance between the lats and divide by numberOfPoints
//                        latitudeModifier = (nextpoi.latitude - lastpoi.latitude) / numberOfPoints;
//                        // Same with lons
//                        longitudeModifier = (nextpoi.longitude - lastpoi.longitude) / numberOfPoints;
//                        
//                        // Loop through the points
//                        for (int i = 0; i < numberOfPoints; i++)
//                        {
//                            
//                            newPoint.latitude = lastpoi.latitude + (latitudeModifier * i);
//                            newPoint.longitude = lastpoi.longitude + (longitudeModifier * i);
//                            MKCoordinateRegion region;
//                            MKCoordinateSpan span;
//                            span.latitudeDelta = 0.0150;
//                            span.longitudeDelta = 0.0150;
//                            region.span = span;
//                            region.center.latitude = newPoint.latitude;
//                            region.center.longitude = newPoint.longitude;
//                            [mv setRegion:region animated:YES];
//                            ann.coordinate = newPoint;
//                            
//                            CLLocation *pointLoc = [[CLLocation alloc] initWithLatitude:newPoint.latitude longitude:newPoint.longitude];
//                            if([startPoint distanceFromLocation:pointLoc] > distance)
//                            {
//                                //NSLog(@"Point Exit Distance %f", [startPoint distanceFromLocation:pointLoc]);
//                                totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:pointLoc];
//                                // eject at the point of the distance we need and set the old location to this point
//                                [self.trackPointArray insertObject:[NSString stringWithFormat:@"%f,%f", pointLoc.coordinate.latitude, pointLoc.coordinate.longitude] atIndex:nextRunIndex];
//                                break;
//                            }
//                            
//                            if(endPoint == sector1EndPoint) sector1Time = lapTime.text;
//                            if(endPoint == sector2EndPoint) sector2Time = lapTime.text;
//                        }
//                    }
//                    else // lets just move to the next point then
//                    {
//                        MKCoordinateRegion region;
//                        MKCoordinateSpan span;
//                        span.latitudeDelta = 0.0150;
//                        span.longitudeDelta = 0.0150;
//                        region.span = span;
//                        region.center.latitude = endPoint.coordinate.latitude;
//                        region.center.longitude = endPoint.coordinate.longitude;
//                        [mv setRegion:region animated:YES];
//                        ann.coordinate = endPoint.coordinate;
//                        
//                        totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:endPoint];
//                        if(endPoint == sector1EndPoint)
//                        {
//                            sector1Time = lapTime.text;
//                        }
//                        if(endPoint == sector2EndPoint) {
//                            sector2Time = lapTime.text;
//                        }
//                        
//                    }
//
//                    distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalPointsDistance * 0.000621371192];
//                    runIndex++;
//                    
//                    if(runIndex == self.trackPointArray.count)
//                    {
//                        //NSLog([NSString stringWithFormat:@"Lap Distance %.2f miles", totalPointsDistance * 0.000621371192]);
//                        //End of lap
//                        runIndex = 0;
//                        lapCounter++;
//                        lapsLabel.text = [NSString stringWithFormat:@"%d Laps", (int)lapCounter];
//                        [self playSound:@"beep-8" :@"mp3"];
//                        
//                        sector1Time = lapTime.text;
//                        sector2Time = lapTime.text;
//                        sector3Time = lapTime.text;
//                        
//                        // Save Sectors and Lap Times
//                        NSDictionary *runLap = @{@"1": sector1Time,
//                                                 @"2": sector2Time,
//                                                 @"3": sector3Time,
//                                                 @"Lap": lapTime.text};
//                        
//                        if(runLaps == nil) runLaps = [[NSMutableDictionary alloc] init];
//                        [runLaps setObject:runLap forKey:[NSString stringWithFormat:@"%d",(int)lapCounter]];
//                        
//                        // Convert to Date
//                        NSDate *currentDate = [NSDate date];
//                        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:lastLapDate];
//                        //timeInterval += secondsAlreadyRun;
//                        NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                        [dateFormatter setDateFormat:@"mm:ss.SS"];
//                        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
//                        lapTime.text = [dateFormatter stringFromDate:timerDate];
//                        lastLapDate = [NSDate date];
//                        
//                        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FastestLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
//                        {
//                            // fastest lap
//                            [newRunAchievements setObject:@"New Fastest Lap" forKey:@"FastestLap"];
//                            [[MessageBarManager sharedInstance] showMessageWithTitle:@"New Fastest Lap"
//                                                                         description:[NSString stringWithFormat:@"Timed at : %@", [dateFormatter stringFromDate:timerDate]]
//                                                                                type:MessageBarMessageTypeInfo];
//                        }
//                        
//                        //Check any achivements
//                        [self checkAchivementsOnLapFinish];
//                    }
//
//                } // end if Runner
//                
//            } // end Annotation Loop
        }
        else // no old location
        {
            totalPointsDistance = 0;
        }// no Location
    } // Timer not set
}

-(void)checkAchivementsOnLapFinish
{
    if(newRunAchievements == nil) newRunAchievements = [[NSMutableDictionary alloc] init];
    // First time the app has been run
    
    if(lapCounter == 1)
    {
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstRun"] withManagedObjectContext:self.managedObjectContext] == 0)
        {
            [newRunAchievements setObject:@"Well done on starting your First Run" forKey:@"FirstRun"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:@"Started Your First Run"
                                                                type:MessageBarMessageTypeInfo];
        }
        
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
        {
            // First ever lap completed
            [newRunAchievements setObject:@"You have Completed your First Lap" forKey:@"FirstLap"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:@"Completed Your First Lap"
                                                                type:MessageBarMessageTypeInfo];
        }
        
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstTrackLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
        {
            // First lap of the track
            [newRunAchievements setObject:@"You have completed your First Lap For" forKey:@"FirstTrackLap"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:[NSString stringWithFormat:@"Completed Your First Lap For %@", [self.trackInfo objectForKey:@"Race"]]
                                                                type:MessageBarMessageTypeInfo];
        }
    } // end of check on first lap
    
    if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"HalfRaceDistance"]  withManagedObjectContext:self.managedObjectContext] == 0)
    {
        [newRunAchievements setObject:@"You have completed half race distance for" forKey:@"HalfRaceDistance"];
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                     description:[NSString stringWithFormat:@"Completed half the distance of %@", [self.trackInfo objectForKey:@"Race"]]
                                                            type:MessageBarMessageTypeInfo];
    }
    
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

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"finishRunSegue"]) {
        
        [self.timeLabel stop];
        [self.timeLabel reset];
        [self.locationManager stopUpdatingLocation];
        
        RunFinishViewController *rfvc = segue.destinationViewController;
        [self.trackInfo setObject:totalRunTime forKey:@"runTime"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%d", (int)lapCounter] forKey:@"runLaps"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalPointsDistance * 0.000621371192] forKey:@"runDistance"];

        //Add Laps, achivements and Sectors Dictionary
        if (runLaps != nil)[self.trackInfo setObject:runLaps forKey:@"runLapsInfo"];
        if (newRunAchievements != nil)[self.trackInfo setObject:newRunAchievements forKey:@"runAchivementsInfo"];
        
        [self.trackInfo setObject:self.runPointArray forKey:@"runPointArray"];
        rfvc.trackInfo = self.trackInfo;
    }
}

- (IBAction)unwindToRunStart:(UIStoryboardSegue *)unwindSegue
{
    // Put back to original state
    [self reset];
}
    
-(void)reset
{
    self.timerState = timerStopped;
    lapCounter = 0;
    _trackInfo = nil;
    distanceLabel.text = @"Track Distance";
    lapsLabel.text = @"Laps";
    startBtn.enabled = FALSE;
    timer = nil;
    totalRunTime = nil;
    [self.timeLabel reset];
    [startBtn setTitle:@"START" forState:UIControlStateNormal];
}


#pragma mark Sounds
- (void)playSound :(NSString *)fName :(NSString *) ext{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
