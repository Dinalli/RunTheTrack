//
//  RunViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunViewController.h"
#import "RunFinishViewController.h"
#import "StartFinishAnnotation.h"
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

@interface RunViewController ()

@property (strong, nonatomic) IBOutlet TTCounterLabel *timeLabel;
@property enum TimerState timerState;

@end

@implementation RunViewController

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    startCountdownShown = NO;
    haveMusicToPlay = NO;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    synth = [[AVSpeechSynthesizer alloc] init];
    synth.delegate = self;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.useMotion)
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Use Motion"
                                                     description:@"You are set up to use Motion for this run. Is this correct?"
                                                            type:MessageBarMessageTypeError];
    }
    
    self.managedObjectContext = appDelegate.
    managedObjectContext;
    
    [self customiseAppearance];
    
	// Do any additional setup after loading the view.
    musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    
    //Listen to notification of track playing changing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:musicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    self.timerState = timerStopped;
    lapCounter = 0;
    
    [self.navigationItem setTitle:[self.trackInfo objectForKey:@"Race"]];
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    
    self.navigationItem.titleView=tlabel;
    
    trackBackImage.image = [UIImage imageNamed:[self.trackInfo objectForKey:@"mapimage"]];
                            
    lapsLabel.text = @"0";
    totalTrackDistance = [[self.trackInfo objectForKey:@"Distance"] floatValue];
    totalTrackDistance = totalTrackDistance / 0.000621371192;
    
    [self startTracking];
    sector1Time = @"";
    sector2Time = @"";
    sector1savedforLap = NO;
    sector2savedforLap = NO;
    
    if(runAltitudeArray == nil) runAltitudeArray = [[NSMutableArray alloc] init];

    [CommonUtils shadowAndRoundView:runInfoView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:@"willEnterForeground"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fromForeground) name:@"willEnterForeground" object:nil];
}


-(void)fromForeground
{
    if(appDelegate.useMotion && self.timerState == timerStarted)
    {
        NSLog(@"update motion from ViewWillAppear");
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Updating Motion Updates"
                                                     description:@"Please wait while we update your motion progress."
                                                            type:MessageBarMessageTypeInfo];
        
        [cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            
            stepCounter = stepCounter + numberOfSteps;
            
            noOfSteps.hidden = NO;
            noOfSteps.text = [NSString stringWithFormat:@"Steps %d", numberOfSteps];

                CGFloat distance = 0;
                distance = numberOfSteps * appDelegate.runMotionDistance;
            NSLog(@"updating distance in viewWillAppear motion %f", distance);
                totalLocationDistance = totalLocationDistance + distance;
                [self moveAnnotaionWithDistance:distance];
        }];

    }
}

- (void)customiseAppearance {
    [self.timeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:65]];
    [self.timeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:65]];
    
    // The font property of the label is used as the font for H,M,S and MS
    [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15]];
    
    // Default label properties
    self.timeLabel.textColor = [UIColor blackColor];
    
    // After making any changes we need to call update appearance
    [self.timeLabel updateApperance];
}

#pragma mark start stop run
- (IBAction)startStop:(id)sender
{
    if(self.timerState == timerStopped)
    {
        [self textToSpeak:@"Start your run now"];
        
        if(haveMusicToPlay) [musicPlayer play];
        
        if([startBtn.titleLabel.text isEqualToString:@"RESUME"])
        {
            if(appDelegate.useMotion)
            {
                [self enableCoreMotion];
            }
            else
            {
                [self.locationManager startUpdatingLocation];
            }
        }
        startDate = [NSDate date];
        lastLapDate = startDate;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [startBtn setTitle:@"STOP" forState:UIControlStateNormal];
        self.timerState = timerStarted;
        [self.timeLabel start];
        btnFinish.hidden = YES;
        
        if(appDelegate.useMotion)
        {
            [self enableCoreMotion];
        }
    }
    else if(self.timerState == timerStarted)
    {
        [self.timeLabel stop];
        [self pauseTimer:timer];
        [startBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        self.timerState = timerStopped;
        btnFinish.hidden = NO;
        finishDate = [NSDate date];
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
        appDelegate.musicIsPlaying = YES;
        haveMusicToPlay = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)playbackStateDidChanged:(NSNotification *)notification
{
}

#pragma tracking setup

-(void)startTracking
{
    self.runPointArray  = [[NSMutableArray alloc] init];
    
    if(appDelegate.useMotion)
    {
        noOfSteps.hidden = NO;
        runPace.hidden = YES;
    }
    else
    {
        runPace.hidden = NO;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone; // setting this to 5.0 as it seems to be best and stop jitters.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.activityType = CLActivityTypeFitness;
        [self.locationManager startUpdatingLocation];
        motionActivityIndicator.image = [UIImage imageNamed:@"gps.png"];
    }
}


-(void)startCountdown
{
    startCountdownShown = YES;
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
                motionActivityIndicator.image = [UIImage imageNamed:@"motionwalk.png"];
            }else if (activity.running)
            {
                motionActivityIndicator.image = [UIImage imageNamed:@"motionrun.png"];
            }
        }];
    }
    
    if([CMStepCounter isStepCountingAvailable])
    {
        if(cmStepCounter == nil) cmStepCounter = [[CMStepCounter alloc] init];
        
        [cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
            
            
//            [cmStepCounter queryStepCountStartingFrom:startDate to:[NSDate date] toQueue:[NSOperationQueue mainQueue] withHandler:^(NSInteger numberOfSteps, NSError *error) {
            
            NSLog(@"updating steps %d in enable motion", numberOfSteps);
                stepCounter = stepCounter + numberOfSteps;
                
                noOfSteps.hidden = NO;
                noOfSteps.text = [NSString stringWithFormat:@"Steps %d", numberOfSteps];
                
                if(self.timerState == timerStarted)
                {
                    
                    CGFloat distance = 0;
                    distance = numberOfSteps * appDelegate.runMotionDistance;
                    NSLog(@"updating distance in enable motion %f", distance);
                    totalLocationDistance = totalLocationDistance + distance;
                    [self moveAnnotaionWithDistance:distance];
                }
//            }];
        }];
    }
}

-(void)moveAnnotaionWithDistance:(CGFloat)distance
{
    if (distance > 0)
    {
        if([appDelegate useKMasUnits])
        {
            distanceLabel.text =  [NSString stringWithFormat:@"%.2f", totalLocationDistance / 1000];
            distanceMeasure.text = @"km";
        }
        else
        {
            distanceLabel.text =  [NSString stringWithFormat:@"%.2f", totalLocationDistance * 0.000621371192];
            distanceMeasure.text = @"miles";
        }
        
        // Calculate the lap distance for the lap
        
        runLapsFloat = totalLocationDistance / totalTrackDistance;
        lapsLabel.text = [NSString stringWithFormat:@"%.2f", runLapsFloat];
        
        // Have we passed a sector then save info
        
        double integral;
        double fractional = modf(runLapsFloat, &integral);

        //Sector 1
        if (fractional > 0.33333 && !sector1savedforLap)
        {
            [self playSound:@"beep-8" :@"mp3"];
            sector1Date = [NSDate date];
            sector1Loc = [self.runPointArray lastObject];
            if(sector3Date == nil)
            {
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

                NSDateComponents *components = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                    fromDate:startDate
                                                                      toDate:sector1Date
                                                                     options:0];
                sector1Time = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
                [self textToSpeak:[NSString stringWithFormat:@"Sector One Time %@",[CommonUtils timeFormattedStringForSpeech:(int)[components hour] :(int)[components minute] :(int)[components second]]]];
                
                if([appDelegate useKMasUnits])
                {
                    runPace.text = [NSString stringWithFormat:@"%@ pk",
                                    [CommonUtils paceFromTimeAndDistanceKm:(int)[components hour] :(int)[components minute] :(int)[components second] :totalLocationDistance]];
                }
                else
                {
                    runPace.text = [NSString stringWithFormat:@"%@ pm",
                                    [CommonUtils paceFromTimeAndDistanceMiles:(int)[components hour] :(int)[components minute] :(int)[components second] :(totalLocationDistance * 0.000621371192)]];
                }
            }
            else{
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

                NSDateComponents *components = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                    fromDate:sector3Date
                                                                      toDate:sector1Date
                                                                     options:0];
                sector1Time = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
                [self textToSpeak:[NSString stringWithFormat:@"Sector One Time %@",[CommonUtils timeFormattedStringForSpeech:(int)[components hour] :(int)[components minute] :(int)[components second]]]];
                
                NSDateComponents *paceComponents = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                        fromDate:startDate
                                                                          toDate:sector1Date
                                                                         options:0];
                
                if([appDelegate useKMasUnits])
                {
                    runPace.text = [NSString stringWithFormat:@"%@ pk",
                                    [CommonUtils paceFromTimeAndDistanceKm:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :totalLocationDistance]];
                }
                else
                {
                    runPace.text = [NSString stringWithFormat:@"%@ pm",
                                    [CommonUtils paceFromTimeAndDistanceMiles:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :(totalLocationDistance * 0.000621371192)]];
                }

            }
            
            sector1savedforLap = YES;
        }
        
        
        // Sector 2
        if (fractional > 0.6666 && !sector2savedforLap)
        {
            [self playSound:@"beep-8" :@"mp3"];
            sector2Date = [NSDate date];
            sector2Loc = [self.runPointArray lastObject];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            
            NSDateComponents *components = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                fromDate:sector1Date
                                                                  toDate:sector2Date
                                                                 options:0];
            sector2Time = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
            
            [self textToSpeak:[NSString stringWithFormat:@"Sector Two Time %@",[CommonUtils timeFormattedStringForSpeech:(int)[components hour] :(int)[components minute] :(int)[components second]]]];
            
            NSDateComponents *paceComponents = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                    fromDate:startDate
                                                                      toDate:sector2Date
                                                                     options:0];
            
            if([appDelegate useKMasUnits])
            {
                runPace.text = [NSString stringWithFormat:@"%@ pk",
                                [CommonUtils paceFromTimeAndDistanceKm:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :totalLocationDistance]];
            }
            else
            {
                runPace.text = [NSString stringWithFormat:@"%@ pm",
                                [CommonUtils paceFromTimeAndDistanceMiles:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :(totalLocationDistance * 0.000621371192)]];
            }
            
            sector2savedforLap = YES;

        }
        
        // Have we completed a lap
        if(lapCounter  != (int)floorf(runLapsFloat))
        {
            [self playSound:@"beep_2" :@"mp3"];
            sector3Date = [NSDate date];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

            NSDateComponents *components = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                fromDate:sector2Date
                                                                  toDate:sector3Date
                                                                 options:0];
            sector3Time = [CommonUtils timeFormattedStringForValue:(int)[components hour] :(int)[components minute] :(int)[components second]];
            
            NSDateComponents *lapComponents = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                fromDate:lastLapDate
                                                                  toDate:sector3Date
                                                                 options:0];
            NSString *lapTimeDiff = [CommonUtils timeFormattedStringForValue:(int)[lapComponents hour] :(int)[lapComponents minute] :(int)[lapComponents second]];
            
            
            NSDateComponents *paceComponents = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                   fromDate:startDate
                                                                     toDate:sector3Date
                                                                    options:0];

            if([appDelegate useKMasUnits])
            {
                runPace.text = [NSString stringWithFormat:@"%@ pk",
                                [CommonUtils paceFromTimeAndDistanceKm:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :totalLocationDistance]];
            }
            else
            {
                runPace.text = [NSString stringWithFormat:@"%@ pm",
                                [CommonUtils paceFromTimeAndDistanceMiles:(int)[paceComponents hour] :(int)[paceComponents minute] :(int)[paceComponents second] :(totalLocationDistance * 0.000621371192)]];
            }
            
            CLLocation *lapLoc = [self.runPointArray lastObject];
            
            lapCounter = (int)floorf(runLapsFloat);
            NSDictionary *runLap = @{@"1": sector1Time,
                                     @"2": sector2Time,
                                     @"3": sector3Time,
                                     @"1Loc" : sector1Loc,
                                     @"2Loc" : sector2Loc,
                                     @"Lap": lapTimeDiff,
                                     @"LapPace": runPace.text,
                                     @"LapLat": [NSString stringWithFormat:@"%f",lapLoc.coordinate.latitude] ,
                                     @"LapLong":[NSString stringWithFormat:@"%f",lapLoc.coordinate.longitude]};

            
            [self textToSpeak:[NSString stringWithFormat:@"Lap %d Time %@", lapCounter,[CommonUtils timeFormattedStringForSpeech:(int)[lapComponents hour] :(int)[lapComponents minute] :(int)[lapComponents second]]]];
            
            if(runLapsInfoDict == nil) runLapsInfoDict = [[NSMutableDictionary alloc] init];
            [runLapsInfoDict setObject:runLap forKey:[NSString stringWithFormat:@"%d",lapCounter]];
            sector1savedforLap = NO;
            sector2savedforLap = NO;
            sector1Time = @"";
            sector2Time = @"";
            sector1Loc = nil;
            sector2Loc = nil;
        }
    }
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(self.timerState == timerStarted)
    {
        CLLocation *newLocation = [locations lastObject];
        [runAltitudeArray addObject:[NSDictionary dictionaryWithObjects:@[[CommonUtils formattedStringFromDate:[NSDate date]],[NSString stringWithFormat:@"%f", newLocation.altitude]] forKeys:@[@"time",@"altitude"]]];

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
            totalLocationDistance = 0;
        }// no Location
        
    } // Timer not set
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    [self.timeLabel stop];
    [self pauseTimer:timer];
    [startBtn setTitle:@"RESUME" forState:UIControlStateNormal];
    self.timerState = timerStopped;
    btnFinish.hidden = NO;
    finishDate = [NSDate date];
    NSLog(@"Locations paused");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"Resuming location Updates");
    
    [[MessageBarManager sharedInstance] showMessageWithTitle:@"Location Updates Resumed"
                                                 description:@"No movement had been detected for a while, so updates were paused."
                                                        type:MessageBarMessageTypeError];
}

#pragma mark Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"finishRunSegue"]) {
        
        if (haveMusicToPlay)[musicPlayer stop];
        [self.timeLabel stop];
        [self.locationManager stopUpdatingLocation];
        
        RunFinishViewController *rfvc = segue.destinationViewController;
        [self.trackInfo setObject:totalRunTime forKey:@"runTime"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%ld",[self.timeLabel getValue]] forKey:@"timeLabel"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f", runLapsFloat] forKey:@"runLaps"];
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalLocationDistance] forKey:@"runDistance"];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *components = [gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                            fromDate:startDate
                                                              toDate:finishDate
                                                             options:0];
        
        if([appDelegate useKMasUnits])
        {
            runPace.text = [NSString stringWithFormat:@"%@ pk",
                            [CommonUtils paceFromTimeAndDistanceKm:(int)[components hour] :(int)[components minute] :(int)[components second] :totalLocationDistance]];
        }
        else
        {
            runPace.text = [NSString stringWithFormat:@"%@ pm",
                            [CommonUtils paceFromTimeAndDistanceMiles:(int)[components hour] :(int)[components minute] :(int)[components second] :(totalLocationDistance * 0.000621371192)]];
        }
        
        [self.trackInfo setObject:runPace.text forKey:@"runPace"];
        
        if(appDelegate.useMotion)
        {
            [self.trackInfo setObject:@"MotionRun" forKey:@"runType"];
            [self.trackInfo setObject:[NSString stringWithFormat:@"%d", stepCounter] forKey:@"runSteps"];
        }
        else
        {
            [self.trackInfo setObject:@"GPSRun" forKey:@"runType"];
            [self.trackInfo setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"runSteps"];
        }
        
        //Add Laps, achivements and Sectors Dictionary
        //Lets clear up any sectors on not complete laps then
        
        lapCounter = (int)floorf(runLapsFloat);
            
        NSMutableDictionary *runLap = [[NSMutableDictionary alloc] init];
        
        if(sector1Time && ![sector1Time isEqualToString:@""])
        {
            [runLap setObject:sector1Time forKey:@"1"];
            [runLap setObject:sector1Loc forKey:@"1Loc"];
        }
  
        if(sector2Time && ![sector2Time isEqualToString:@""])
        {
            [runLap setObject:sector2Time forKey:@"2"];
            [runLap setObject:sector2Loc forKey:@"2Loc"];
        }
        
        if(runLapsInfoDict == nil) runLapsInfoDict = [[NSMutableDictionary alloc] init];
        [runLapsInfoDict setObject:runLap forKey:[NSString stringWithFormat:@"%d",lapCounter]];
        
        if (runLapsInfoDict != nil)[self.trackInfo setObject:runLapsInfoDict forKey:@"runLapsInfo"];
        if (runAltitudeArray != nil)[self.trackInfo setObject:runAltitudeArray forKey:@"runAltitude"];
        
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
    distanceLabel.text = @"0";
    lapsLabel.text = @"0";
    startBtn.enabled = FALSE;
    timer = nil;
    totalRunTime = nil;
    [self.timeLabel reset];
    [startBtn setTitle:@"START" forState:UIControlStateNormal];
}


#pragma mark Sounds
- (void)playSound :(NSString *)fName :(NSString *) ext{
   
    if(appDelegate.soundEnabled)
    {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Speech

-(void)textToSpeak:(NSString *)textToSpeak
{
    if(appDelegate.soundEnabled)
    {
        AVSpeechUtterance *utt = [[AVSpeechUtterance alloc] initWithString:textToSpeak];
        utt.rate = 0.2;
        [synth speakUtterance:utt];
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if(haveMusicToPlay) [musicPlayer play];
}

@end
