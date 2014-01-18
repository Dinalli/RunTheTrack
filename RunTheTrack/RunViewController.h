//
//  RunViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"
#import "TrackInfoViewController.h"
#import "TTCounterLabel.h"
#import "YLProgressBar.h"

@interface RunViewController : UIViewController<TTCounterLabelDelegate, MPMediaPickerControllerDelegate, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate>
{
    MPMusicPlayerController *musicPlayer;
    
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIButton *btnFinish;
    IBOutlet UILabel *lapTime;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *distanceMeasure;
    IBOutlet UILabel *runPace;
    
    IBOutlet UILabel *noOfSteps;
    NSInteger stepCounter;
    
    IBOutlet UILabel *lapsLabel;
    IBOutlet UIButton *startBtn;
    
    IBOutlet UILabel *motionActivityIndicator;
    IBOutlet UIImageView *trackBackImage;
    
    IBOutlet UIView *runInfoView;
    IBOutlet UIView *runTimeView;
    
    NSTimer *timer;
    
    NSDate *startDate;
    NSDate *lapDate;
    NSDate *lastLapDate;
    NSDate *sectorDate;
    NSTimeInterval secondsAlreadyRun;
    NSInteger lapCounter;
    
    int runIndex;
    int sector1Count;
    int sector2Count;
    
    NSMutableDictionary *runLaps;
    NSString *sector1Time;
    NSString *sector2Time;
    NSString *sector3Time;
    NSString *recordedlapTime;
    NSString *totalRunTime;
    
    NSMutableArray *runAltitudeArray;
    NSString *fastestLap;
    
    AppDelegate *appDelegate;
    
    CLLocation *sector1EndPoint;
    CLLocation *sector2EndPoint;
    
    CMMotionActivityManager *cmActivityMgr;
    CMStepCounter *cmStepCounter;
    CLLocationDistance totalLocationDistance;
    float totalTrackDistance;
    float runLapsFloat;
    
    AVSpeechSynthesizer *synth;
    
    BOOL startCountdownShown;
}

@property (nonatomic, strong) NSMutableArray *runPointArray;
@property (nonatomic) NSMutableDictionary *trackInfo;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatWithIndicator;

- (void)initFlatWithIndicatorProgressBar;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (IBAction)unwindToRunStart:(UIStoryboardSegue *)unwindSegue;

@end
