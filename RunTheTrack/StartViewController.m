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
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    synth = [[AVSpeechSynthesizer alloc] init];
    synth.delegate = self;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self customiseAppearance];
    
	// Do any additional setup after loading the view.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //Listen to notification of track playing changing
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerPlaybackStateDidChange) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
//    [musicPlayer beginGeneratingPlaybackNotifications];
    
    self.timerState = timerStopped;
    lapCounter = 0;
    
    [self.navigationItem setTitle:[self.trackInfo objectForKey:@"Race"]];
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    
    self.navigationItem.titleView=tlabel;
    
    lapsLabel.text = @"0 Laps";
    
    [self startTracking];
    [self addTrackPoints];
    
    currentAchievements = [CoreDataHelper searchObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@", [self.trackInfo objectForKey:@"Race"]] withSortKey:nil sortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    if(newRunAchievements == nil) newRunAchievements = [[NSMutableDictionary alloc] init];
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
        
        [self textToSpeak:@"Start your run"];
        TFLog(@"Run Started");
        
        if([startBtn.titleLabel.text isEqualToString:@"RESUME"])
        {
            if(appDelegate.useMotion)
            {
                [self enableCoreMotion];
            }
            else
            {
                [self.locationManager startUpdatingLocation];
                TFLog(@"Restarted Location Updates");
            }
        }
        
        startDate = [NSDate date];
        lastLapDate = startDate;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
        self.timerState = timerStarted;
        [self.timeLabel start];
        btnFinish.hidden = YES;
        
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstRun"] withManagedObjectContext:self.managedObjectContext] == 0)
        {
            [newRunAchievements setObject:@"Well done on starting your First Run" forKey:@"FirstRun"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:@"Started Your First Run"
                                                                type:MessageBarMessageTypeInfo];
            [self textToSpeak:@"Well done on starting your First Run"];
        }
    }
    else if(self.timerState == timerStarted)
    {
        [self.timeLabel stop];
        [self pauseTimer:timer];
        [startBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        self.timerState = timerStopped;
        btnFinish.hidden = NO;
    }
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
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMovie];
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
        appDelegate.musicIsPlaying = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        motionActivityIndicator.hidden = YES;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 1.0; // setting this to 5.0 as it seems to be best and stop jitters.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startUpdatingLocation];
        
        TFLog(@"Location Updates Started");
    }
}

-(void)addTrackPoints
{
    [mv removeAnnotations:mv.annotations];
    CLLocationCoordinate2D poi;
    CLLocationDistance totalDistance;
    CLLocationDistance sectorCalcDistance;
    
    totalTrackDistance = 0;

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
            span.latitudeDelta = 0.0150;
            span.longitudeDelta = 0.0150;
            region.span = span;
            region.center.latitude = [lat doubleValue];
            region.center.longitude = [lng doubleValue];
            [mv setRegion:region animated:YES];
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalTrackDistance = totalTrackDistance + [lastLocation distanceFromLocation:nextLocation];
        }
        else
        {
            [self.trackPointArray addObject:coordPoint];
        }
    }
    
    NSLog(@"TOTAL TRACK DISTANCE %.2f", totalTrackDistance / 1000);
    
    MKRunnerAnnotation *runner = [[MKRunnerAnnotation alloc] init];
    runner.coordinate = poi;
    runner.title = @"Runner";
    [mv addAnnotation:runner];
    
    // add the sector points for 1, 2
    // divide the total track distance by 3
    sectorCalcDistance = totalTrackDistance / 3;
    totalDistance = 0;
    bool sector1Set = FALSE;
    self.trackSectorPointArray = [[NSMutableArray alloc] init];
    
    for(NSString *coordPoint in sectorArray)
    {
        if([self.trackSectorPointArray count] > 0)
        {
            NSArray *latlong = [coordPoint componentsSeparatedByString:@","];
            NSString *lat = [latlong objectAtIndex:0];
            NSString *lng = [latlong objectAtIndex:1];
            
            NSArray *oldlatlong = [[self.trackSectorPointArray lastObject] componentsSeparatedByString:@","];
            NSString *oldlat = [oldlatlong objectAtIndex:0];
            NSString *oldlng = [oldlatlong objectAtIndex:1];
            
            CLLocationCoordinate2D oldpoi = CLLocationCoordinate2DMake([oldlat doubleValue], [oldlng doubleValue]);
            poi = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
            
            CLLocationCoordinate2D coordinates[2];
            coordinates[0] = oldpoi;
            coordinates[1] = poi;
            
            [self.trackSectorPointArray addObject:coordPoint];
            
            CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:[oldlat doubleValue] longitude:[oldlng doubleValue]];
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            totalDistance = totalDistance + [lastLocation distanceFromLocation:nextLocation];
            
            if(totalDistance > (sectorCalcDistance))
            {
                if(!sector1Set)
                {
                    sector1EndPoint = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
                    sector1Set = TRUE;
                    
                    Sector1Annotaion *sector1Ann = [[Sector1Annotaion alloc] init];
                    sector1Ann.coordinate = CLLocationCoordinate2DMake(sector1EndPoint.coordinate.latitude, sector1EndPoint.coordinate.longitude);
                    sector1Ann.title = @"Sector1";
                    [mv addAnnotation:sector1Ann];
                }
            }
            
            if(totalDistance > (sectorCalcDistance * 2))
            {
                sector2EndPoint = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lng floatValue]];
                
                Sector2Annotation *sector2Ann = [[Sector2Annotation alloc] init];
                sector2Ann.coordinate = sector2EndPoint.coordinate;
                sector2Ann.title = @"Sector2";
                [mv addAnnotation:sector2Ann];
                break;
            }
        }
        else
        {
            [self.trackSectorPointArray addObject:coordPoint];
        }
    }
    
    // Add start finish indicator
    NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
    StartFinishAnnotation *startfinish = [[StartFinishAnnotation alloc] init];
    CLLocationCoordinate2D startFinishPoi = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Lat"] doubleValue], [[startFinishDict objectForKey:@"Long"] doubleValue]);
    startfinish.coordinate = startFinishPoi;
    startfinish.title = @"Start Finish";
    [mv addAnnotation:startfinish];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0150;
    span.longitudeDelta = 0.0150;
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
    __block CMMotionActivity *currentActivity = nil;
    if([CMMotionActivityManager isActivityAvailable])
    {
        motionActivityIndicator.hidden = NO;
        if(cmActivityMgr == nil) cmActivityMgr = [[CMMotionActivityManager alloc] init];
        
        [cmActivityMgr startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            currentActivity = activity;
            if(activity.walking)
            {
                motionActivityIndicator.text = @"walk";
            }else if (activity.running)
            {
                motionActivityIndicator.text = @"run";
            }
        }];
    }
    
    if([CMStepCounter isStepCountingAvailable])
    {
        if(cmStepCounter == nil) cmStepCounter = [[CMStepCounter alloc] init];
                
        [cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            
            if(self.timerState == timerStarted)
            {
                CGFloat distance = 0;
                if(currentActivity.walking)
                {
                    distance = numberOfSteps * appDelegate.walkMotionDistance; // Walking
                }else if (currentActivity.running)
                {
                    distance = numberOfSteps * appDelegate.runMotionDistance; // Running
                }
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
            NSLog(@"moveAnnotaionWithDistance %f", distance);
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
            //NSLog(@"Outside - Distance %f - Poly Distance %f", distance, polyDistance);
            
            if (distance > 0)
            {
                int loopCount = 0;
                while (distance > polyDistance) {
                    loopCount ++;
                    runIndex++;
                    
                    //NSLog(@"Greater Count %d - Distance %f - Poly Distance %f", loopCount, distance, polyDistance);
                    
                    totalPointsDistance = totalPointsDistance + polyDistance;
                    distance = distance - polyDistance;
                    
                    if(runIndex == self.trackPointArray.count-1)
                    {
                        nextRunIndex = 0;
                    }
                    else{
                        nextRunIndex = runIndex+1;
                    }
                    
                    lastlatlong = [[self.trackPointArray objectAtIndex:runIndex] componentsSeparatedByString:@","];
                    lastlat = [lastlatlong objectAtIndex:0];
                    lastlng = [lastlatlong objectAtIndex:1];

                    nextlatlong = [[self.trackPointArray objectAtIndex:nextRunIndex] componentsSeparatedByString:@","];
                    nextlat = [nextlatlong objectAtIndex:0];
                    nextlng = [nextlatlong objectAtIndex:1];

                    startPoint = [[CLLocation alloc] initWithLatitude:[lastlat doubleValue] longitude:[lastlng doubleValue]];
                    endPoint = [[CLLocation alloc] initWithLatitude:[nextlat doubleValue] longitude:[nextlng doubleValue]];
                    polyDistance = [startPoint distanceFromLocation:endPoint];
                    
                    MKCoordinateRegion region;
                    MKCoordinateSpan span;
                    span.latitudeDelta = 0.0150;
                    span.longitudeDelta = 0.0150;
                    region.span = span;
                    region.center.latitude = endPoint.coordinate.latitude;
                    region.center.longitude = endPoint.coordinate.longitude;
                    [mv setRegion:region animated:YES];
                    ann.coordinate = endPoint.coordinate;
                    
                    runLapsFloat = totalPointsDistance / totalTrackDistance;
                    lapsLabel.text = [NSString stringWithFormat:@"%.2f Laps", runLapsFloat];
                    
                    if([appDelegate useKMasUnits])
                    {
                        distanceLabel.text =  [NSString stringWithFormat:@"%.2f km", totalPointsDistance / 1000];
                    }
                    else
                    {
                        distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalPointsDistance * 0.000621371192];
                    }
                    
                    if(distance < 1)
                    {
                        break;
                    }
                }
                
                // move the annotation correct last distance
                CLLocationCoordinate2D lastpoi = CLLocationCoordinate2DMake([lastlat doubleValue], [lastlng doubleValue]);
                CLLocationCoordinate2D nextpoi = CLLocationCoordinate2DMake([nextlat doubleValue], [nextlng doubleValue]);
                
                double latitudeModifier;    // Distance to add/subtract to each latitude point
                double longitudeModifier;   // Distance to add/subtract to each longitude point
                
                int numberOfPoints = 500;   // The number of points you want between the two points
                
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
                        totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:pointLoc];
                        // eject at the point of the distance we need and set the old location to this point
                        int insertIndex = nextRunIndex;
                        if (nextRunIndex == self.trackPointArray.count -1)
                        {
                                //End of lap
                                runIndex = 0;
                                nextRunIndex = 0;
                                insertIndex = insertIndex-1;
                                lapCounter++;
                                [self playSound:@"beep-8" :@"mp3"];
                                [self textToSpeak:[NSString stringWithFormat:@"Lap Complete %@",[self.timeLabel getValueString]]];
                                
                                sector3Time = [self.timeLabel getValueString];
                                
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
                                    
                                    [self textToSpeak:[NSString stringWithFormat:@"New Fastest Lap timed at %@", [dateFormatter stringFromDate:timerDate]]];
                                }
                                
                                //Check any achivements
                                [self checkAchivementsOnLapFinish];

                        }
                        [self.trackPointArray insertObject:[NSString stringWithFormat:@"%f,%f", pointLoc.coordinate.latitude, pointLoc.coordinate.longitude] atIndex:insertIndex];
                        break;
                    }
                }

                
                if([startPoint distanceFromLocation:sector1EndPoint] < 1)
                {
                    NSLog(@"Distance from sector 1 point %f", [endPoint distanceFromLocation:sector1EndPoint]);
                    sector1Time = [self.timeLabel getValueString];
                    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Sector 1 Complete"
                                                                 description:[NSString stringWithFormat:@"Timed at : %@", [self.timeLabel getValueString]]
                                                                        type:MessageBarMessageTypeInfo];
                    
                    
                    [self textToSpeak:[NSString stringWithFormat:@"Sector 1 time %@", [self.timeLabel getValueString]]];

                }
                
                if([startPoint distanceFromLocation:sector2EndPoint] < 1)
                {
                    
                    sector2Time = [self.timeLabel getValueString];
                    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Sector 2 Complete"
                                                                 description:[NSString stringWithFormat:@"Timed at : %@", [self.timeLabel getValueString]]
                                                                        type:MessageBarMessageTypeInfo];
                    
                    [self textToSpeak:[NSString stringWithFormat:@"Sector 2 time %@",[self.timeLabel getValueString]]];

                }
                
                runIndex++;
                
                if([appDelegate useKMasUnits])
                {
                    distanceLabel.text =  [NSString stringWithFormat:@"%.2f km", totalPointsDistance / 1000];
                }
                else
                {
                    distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalPointsDistance * 0.000621371192];
                }
                
                // Calculate the lap distance for the lap
                runLapsFloat = totalPointsDistance / totalTrackDistance;
                lapsLabel.text = [NSString stringWithFormat:@"%.2f Laps", runLapsFloat];
                
                if(runIndex == self.trackPointArray.count)
                {
                    //End of lap
                    runIndex = 0;
                    nextRunIndex = 0;
                    lapCounter++;
                    [self playSound:@"beep-8" :@"mp3"];
                    [self textToSpeak:[NSString stringWithFormat:@"Lap Complete %@",[self.timeLabel getValueString]]];
                    
                    sector3Time = [self.timeLabel getValueString];
                    
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
                        
                        [self textToSpeak:[NSString stringWithFormat:@"New Fastest Lap timed at %@", [dateFormatter stringFromDate:timerDate]]];
                    }
                    
                    //Check any achivements
                    [self checkAchivementsOnLapFinish];
                }
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
        
//        if(newLocation.horizontalAccuracy < 15 && newLocation.verticalAccuracy < 30)
//        {
            CLLocation *oldLocation = [self.runPointArray lastObject];
            CLLocationDistance distance;
            
            //Always add the real location to array so we can show the real route later on
            [self.runPointArray addObject:newLocation];
            
            // No need to do anything if old location is not set
            if(oldLocation != nil)
            {
                distance = [newLocation distanceFromLocation:oldLocation];
                totalLocationDistance = totalLocationDistance + distance;
                [self moveAnnotaionWithDistance:distance];
            }
            else // no old location
            {
                totalPointsDistance = 0;
                totalLocationDistance = 0;
            }// no Location
//        }
//        else
//        {
//            NSLog(@"Location not accurate enough %f  - %f", newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
//            TFLog(@"Location not accurate enough");
//        }
    } // Timer not set
}

-(void)checkAchivementsOnLapFinish
{
    // First time the app has been run
    
    if(lapCounter == 1)
    {
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
        {
            // First ever lap completed
            [newRunAchievements setObject:@"Congradulations, Completed your First Lap" forKey:@"FirstLap"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:@"Completed Your First Lap"
                                                                type:MessageBarMessageTypeInfo];
        }
        
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"FirstTrackLap"]  withManagedObjectContext:self.managedObjectContext] == 0)
        {
            // First lap of the track
            [newRunAchievements setObject:[NSString stringWithFormat:@"Completed Your First Lap For %@", [self.trackInfo objectForKey:@"Race"]] forKey:@"FirstTrackLap"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:[NSString stringWithFormat:@"Completed Your First Lap For %@", [self.trackInfo objectForKey:@"Race"]]
                                                                type:MessageBarMessageTypeInfo];
        }
    } // end of check on first lap
    
    if(totalPointsDistance > (totalTrackDistance / 2))
    {
        if([CoreDataHelper countObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@ AND achievementTrigger = %@", [self.trackInfo objectForKey:@"Race"], @"HalfRaceDistance"]  withManagedObjectContext:self.managedObjectContext] == 0)
        {
            [newRunAchievements setObject:[NSString stringWithFormat:@"Completed half the distance of %@", [self.trackInfo objectForKey:@"Race"]] forKey:@"HalfRaceDistance"];
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Congradulations"
                                                         description:[NSString stringWithFormat:@"Completed half the distance of %@", [self.trackInfo objectForKey:@"Race"]]
                                                                type:MessageBarMessageTypeInfo];
        }
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
        [self.locationManager stopUpdatingLocation];
        TFLog(@"Location Updates Stopped");
        
        RunFinishViewController *rfvc = segue.destinationViewController;
        [self.trackInfo setObject:totalRunTime forKey:@"runTime"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%ld",[self.timeLabel getValue]] forKey:@"timeLabel"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f", runLapsFloat] forKey:@"runLaps"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalPointsDistance] forKey:@"runDistance"];

        //Add Laps, achivements and Sectors Dictionary
        if (runLaps != nil)[self.trackInfo setObject:runLaps forKey:@"runLapsInfo"];
        if (newRunAchievements != nil)[self.trackInfo setObject:newRunAchievements forKey:@"runAchivementsInfo"];
        
        [self.trackInfo setObject:self.runPointArray forKey:@"runPointArray"];
        rfvc.trackInfo = self.trackInfo;        
        
        TFLog(@"Run Laps %.2f", runLapsFloat);
        TFLog(@"Run Distance %.2f",totalPointsDistance);
        TFLog(@"Run Real Distance %.2f",totalLocationDistance);

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
        CLSLog(@"error, file not found: %@", path);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Speech

-(void)textToSpeak:(NSString *)textToSpeak
{
    AVSpeechUtterance *utt = [[AVSpeechUtterance alloc] initWithString:textToSpeak];
    utt.rate = 0.4;
    utt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];
    [synth speakUtterance:utt];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if(appDelegate.musicIsPlaying) [musicPlayer play];
}

@end
