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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self customiseAppearance];
    
	// Do any additional setup after loading the view.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //Listen to notification of track playing changing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicTrackChanged) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
    
    if(musicPlayer.nowPlayingItem)
    {
        currentTrack.text =  [NSString stringWithFormat:@"%@ - %@",[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist],[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle]];
    }
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    self.timerState = timerStopped;
    finishBtn.hidden = YES;
    lapCounter = 0;
    
    [self showMap];
}


- (void)customiseAppearance {
    [self.timeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:55]];
    [self.timeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:55]];
    
    // The font property of the label is used as the font for H,M,S and MS
    [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];
    
    // Default label properties
    self.timeLabel.textColor = [UIColor orangeColor];
    
    // After making any changes we need to call update appearance
    [self.timeLabel updateApperance];
}

#pragma mark start stop run
- (IBAction)startStop:(id)sender
{
    finishBtn.hidden = YES;
    if(self.timerState == timerStopped)
    {
        // Start the timer
        [self playSound:@"beep-8" :@"mp3"];
        startDate = [NSDate date];
        lastLapDate = startDate;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
        if(intervalSeg.selectedSegmentIndex == 1)
        {
            drsLabel.hidden = FALSE;
        }
        else
        {
            drsLabel.hidden = TRUE;
        }
        
        self.timerState = timerStarted;
        self.gpsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(blinkGPS) userInfo:nil repeats:YES];

        // Move the view down to show the map.
        [UIView animateWithDuration:1.5 delay:0.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
            runControlView.frame = CGRectMake(0, self.view.frame.size.height - 100, runControlView.frame.size.width, runControlView.frame.size.height);
                startBtn.frame = CGRectMake(0, 5, 320, 44);
        } completion:^(BOOL finished) {
            trackBtn.hidden = YES;
            intervalSeg.hidden = YES;
            runTypeSeg.hidden = YES;
        }];
        
        [self.timeLabel start];
    }
    else if(self.timerState == timerStarted)
    {
        [self.gpsTimer invalidate];
        [self.timeLabel stop];
        [self pauseTimer:timer];
        [startBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        self.timerState = timerPaused;
        finishBtn.hidden = NO;
        
        // Move the view down to show the map.
        [UIView animateWithDuration:0.5 delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             runControlView.frame = CGRectMake(0, self.view.frame.size.height - 150, runControlView.frame.size.width, runControlView.frame.size.height);
                         } completion:^(BOOL finished) {
                             
                         }];
        
        
    }
    else if(self.timerState == timerPaused)
    {
        [self.timeLabel start];
        [self resumeTimer:timer];
        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
        self.timerState = timerStarted;
        [self.gpsTimer invalidate];
        
        // Move the view down to show the map.
        [UIView animateWithDuration:1.5 delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             runControlView.frame = CGRectMake(0, self.view.frame.size.height - 100, runControlView.frame.size.width, runControlView.frame.size.height);
                         } completion:^(BOOL finished) {
                             
                         }];
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

- (IBAction)trackChosen:(UIStoryboardSegue *)segue
{
    // do any clean up you want
    trackNameLabel.text = [self.trackInfo objectForKey:@"Race"];
    lapsLabel.text = [NSString stringWithFormat:@"0/%@",[self.trackInfo objectForKey:@"Laps"]];
    trackImage.image = [UIImage imageNamed:[self.trackInfo objectForKey:@"mapimage"]];
    [self startTracking];
    [self addTrackPoints];
    startBtn.enabled = TRUE;
    startBtn.hidden = FALSE;
    [trackBtn setTitle:@"CHOOSE TRACK" forState:UIControlStateNormal];
    currentAchievements = [CoreDataHelper searchObjectsInContextWithEntityName:@"RunAchievement" andPredicate:[NSPredicate predicateWithFormat:@"trackname = %@", [self.trackInfo objectForKey:@"Race"]] withSortKey:nil sortAscending:YES withManagedObjectContext:self.managedObjectContext];
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
    currentTrack.text =  [NSString stringWithFormat:@"%@ - %@",[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist],[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle]];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark music player   
-(void)musicTrackChanged
{
    currentTrack.text =  [NSString stringWithFormat:@"%@ - %@",[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist],[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle]];
}

#pragma mark Map view

-(void)showMap
{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 140;
    span.longitudeDelta = 300;
    region.span = span;
    region.center.latitude = [[_trackInfo objectForKey:@"Lat"] doubleValue];
    region.center.longitude = [[_trackInfo objectForKey:@"Long"] doubleValue];
    [mv setRegion:region animated:YES];
}

-(void)startTracking
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1.0; // setting this to 5.0 as it seems to be best and stop jitters.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.trackPointArray = [[NSMutableArray alloc] init];
    self.runPointArray  = [[NSMutableArray alloc] init];
    [self setTimeDuration:0];
    [self.locationManager startUpdatingLocation];
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
    
    MKRunnerAnnotation *runner = [[MKRunnerAnnotation alloc] init];
    runner.coordinate = poi;
    runner.title = @"Runner";
    [mv addAnnotation:runner];
    
    // Add start finish indicator
    NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
    MKPointAnnotation *startfinish = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D startFinishPoi = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Lat"] doubleValue], [[startFinishDict objectForKey:@"Long"] doubleValue]);
    startfinish.coordinate = startFinishPoi;
    startfinish.title = @"Start Finish";
    [mv addAnnotation:startfinish];
    
//    // Add sector 2 start
//    //NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
//    MKPointAnnotation *sector2Start = [[MKPointAnnotation alloc] init];
//    sector2Start.coordinate = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Long"] doubleValue], [[startFinishDict objectForKey:@"Lat"] doubleValue]);
//    sector2Start.title = @"Sector 2";
//    [mv addAnnotation:sector2Start];
//    
//    // Add sector 3 start
//    //NSDictionary *startFinishDict = [_trackInfo objectForKey:@"StartLine"];
//    MKPointAnnotation *sector3Start = [[MKPointAnnotation alloc] init];
//    sector3Start.coordinate = CLLocationCoordinate2DMake([[startFinishDict objectForKey:@"Long"] doubleValue], [[startFinishDict objectForKey:@"Lat"] doubleValue]);
//    sector3Start.title = @"Sector 3";
//    [mv addAnnotation:sector3Start];
    
    
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
    else if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
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
    }
    else
    {
        static NSString *annotationId = @"ID";
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:annotationId];
        UIImage *annImage;
        if([[annotation title] isEqualToString:@"Sector 1"])
        {
           annImage = [UIImage imageNamed:@"sector1.png"];
        }
        else
        {
            annImage = [UIImage imageNamed:@"sector2.png"];
        }
        annotationView.image = annImage;
        return annotationView;

    }
    return nil;
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
            
            // Move to a suitable spot on the track
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
                            span.latitudeDelta = 0.0070;
                            span.longitudeDelta = 0.0070;
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
                                NSLog([NSString stringWithFormat:@"Split Point %.2f miles", totalPointsDistance * 0.000621371192]);
                                
                                // eject at the point of the distance we need and set the old location to this point
                                [self.trackPointArray insertObject:[NSString stringWithFormat:@"%f,%f", pointLoc.coordinate.latitude, pointLoc.coordinate.longitude] atIndex:nextRunIndex];
                                break;
                            }
                        }
                    }
                    else // lets just move to the next point then
                    {
                        MKCoordinateRegion region;
                        MKCoordinateSpan span;
                        span.latitudeDelta = 0.0070;
                        span.longitudeDelta = 0.0070;
                        region.span = span;
                        region.center.latitude = endPoint.coordinate.latitude;
                        region.center.longitude = endPoint.coordinate.longitude;
                        [mv setRegion:region animated:YES];
                        ann.coordinate = endPoint.coordinate;
                        
                        totalPointsDistance = totalPointsDistance + [startPoint distanceFromLocation:endPoint];
                        NSLog([NSString stringWithFormat:@"Next Point %.2f miles", totalPointsDistance * 0.000621371192]);
                        
                    }
                    
                    if(distanceUnit.selectedSegmentIndex == 1)
                    {
                        distanceLabel.text =  [NSString stringWithFormat:@"%.2f km", totalPointsDistance * 1000];
                    }
                    else
                    {
                        distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalPointsDistance * 0.000621371192];
                    }
                }
                runIndex++;
                                
                if(runIndex == self.trackPointArray.count)
                {
                    NSLog([NSString stringWithFormat:@"Lap Distance %.2f miles", totalPointsDistance * 0.000621371192]);
                    //End of lap
                    runIndex = 0;
                    lapCounter++;
                    lapsLabel.text = [NSString stringWithFormat:@"%d Laps", (int)lapCounter];
                    [self playSound:@"beep-8" :@"mp3"];
                    
                    sector3Time = lapTime.text;
                    
                    // Save Sectors and Lap Times
                    NSDictionary *runLap = @{@"1": sector1Time,
                                             @"2": sector2Time,
                                             @"3": sector3Time,
                                             @"Lap": lapTime.text};
                    
                    if(runLaps == nil) runLaps = [[NSMutableDictionary alloc] init];
                    [runLaps setObject:runLap forKey:[NSString stringWithFormat:@"%d",(int)lapCounter]];
                    
                    //Set Lap Time
                    [self setLastLap];
                }
                break;
            }
        }// end Annotation Loop
        else // no old location
        {
            totalPointsDistance = 0;
        }// no Location
    } // Timer not set
}

-(void)setLastLap
{
    // Compare to fastest Lap
    
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

-(void)blinkGPS
{
    [gpsIcon setHidden:(!gpsIcon.hidden)];
}


#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"finishRunSegue"]) {
        
        [self reset];
        
        [self.timeLabel stop];
        [self.timeLabel reset];
        [self.locationManager stopUpdatingLocation];
        
        RunFinishViewController *rfvc = segue.destinationViewController;
        [self.trackInfo setObject:totalRunTime forKey:@"runTime"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%d", (int)lapCounter] forKey:@"runLaps"];
        
        if(distanceUnit.selectedSegmentIndex == 1)
        {
            [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalPointsDistance * 1000] forKey:@"runDistance"];
        }
        else
        {
            [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalPointsDistance * 0.000621371192] forKey:@"runDistance"];
        }
        
        //Add Laps and Sectors Dictionary
        if (runLaps != nil)[self.trackInfo setObject:runLaps forKey:@"runLapsInfo"];
        
        [self.trackInfo setObject:self.runPointArray forKey:@"runPointArray"];
        rfvc.trackInfo = self.trackInfo;
        
        //Add achivements to the trackInfo
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
        finishBtn.hidden = YES;
        lapCounter = 0;
        _trackInfo = nil;
        drsLabel.hidden = FALSE;
        trackBtn.hidden = FALSE;
        trackNameLabel.text = @"Track Name";
        distanceLabel.text = @"Track Distance";
        trackImage.image = nil;
        lapsLabel.text = @"Laps";
        startBtn.enabled = FALSE;
        timer = nil;
        totalRunTime = nil;
        [self.timeLabel reset];
        [startBtn setTitle:@"START" forState:UIControlStateNormal];
        runTypeSeg.hidden = FALSE;
        trackBtn.titleLabel.text = @"CHOOSE TRACK TO START";
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
