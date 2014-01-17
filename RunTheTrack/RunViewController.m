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
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    
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
    
    trackBackImage.image = [[UIImage imageNamed:[self.trackInfo objectForKey:@"mapimage"]] applyExtraLightEffect];
                            
    lapsLabel.text = @"0 Laps";
    totalTrackDistance = [[self.trackInfo objectForKey:@"Distance"] floatValue];
    totalTrackDistance = totalTrackDistance / 0.000621371192;
    
    NSLog(@"Total Track Distance %f", totalTrackDistance);
    
    [self startTracking];
    sector1Time = @"";
    sector2Time = @"";
    
    if(runAltitudeArray == nil) runAltitudeArray = [[NSMutableArray alloc] init];
    
    [self initFlatWithIndicatorProgressBar];
    [self.progressBarFlatWithIndicator setProgress:0.0 animated:YES];
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

- (void)customiseAppearance {
    [self.timeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:75]];
    [self.timeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:75]];
    
    // The font property of the label is used as the font for H,M,S and MS
    [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];
    
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
        // Start the timer
        [self textToSpeak:@"3 2 1 Start your run"];
        
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

-(void)playbackStateDidChanged:(NSNotification *)notification
{
}

#pragma tracking setup

-(void)startTracking
{
    self.runPointArray  = [[NSMutableArray alloc] init];
    
    if(appDelegate.useMotion)
    {
        [self enableCoreMotion];
    }
    else
    {
        motionActivityIndicator.hidden = YES;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone; // setting this to 5.0 as it seems to be best and stop jitters.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startUpdatingLocation];
        
        TFLog(@"Location Updates Started");
    }
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
            
            noOfSteps.hidden = NO;
            noOfSteps.text = [NSString stringWithFormat:@"Steps %d", numberOfSteps];
            
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
    if (distance > 0)
    {
        if([appDelegate useKMasUnits])
        {
            distanceLabel.text =  [NSString stringWithFormat:@"%.2f km", totalLocationDistance / 1000];
        }
        else
        {
            distanceLabel.text =  [NSString stringWithFormat:@"%.2f miles", totalLocationDistance * 0.000621371192];
        }
        
        // Calculate the lap distance for the lap
        
        runLapsFloat = totalLocationDistance / totalTrackDistance;
        lapsLabel.text = [NSString stringWithFormat:@"%.2f Laps", runLapsFloat];
        [self setProgress:runLapsFloat/100 animated:YES];
        
        
        
        // Have we passed a sector then save info
        // Have we completed a lap
    }
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(self.timerState == timerStarted)
    {
        CLLocation *newLocation = [locations lastObject];
        
//        if(newLocation.altitude != 0)
//        {
            [runAltitudeArray addObject:[NSDictionary dictionaryWithObjects:@[[CommonUtils formattedStringFromDate:[NSDate date]],[NSString stringWithFormat:@"%f", newLocation.altitude]] forKeys:@[@"time",@"altitude"]]];
//        }
        
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
        [self.trackInfo setObject:[NSString stringWithFormat:@"%.2f",totalLocationDistance] forKey:@"runDistance"];
        
        if(appDelegate.useMotion)
        {
            [self.trackInfo setObject:@"MotionRun" forKey:@"runType"];
        }
        else
        {
            [self.trackInfo setObject:@"GPSRun" forKey:@"runType"];
        }
        
        //Add Laps, achivements and Sectors Dictionary
        if (runLaps != nil)[self.trackInfo setObject:runLaps forKey:@"runLapsInfo"];
        //if (newRunAchievements != nil)[self.trackInfo setObject:newRunAchievements forKey:@"runAchivementsInfo"];
        if (runAltitudeArray != nil)[self.trackInfo setObject:runAltitudeArray forKey:@"runAltitude"];
        
        [self.trackInfo setObject:self.runPointArray forKey:@"runPointArray"];
        rfvc.trackInfo = self.trackInfo;
        
        TFLog(@"Run Laps %.2f", runLapsFloat);
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
