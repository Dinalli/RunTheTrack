//
//  StartViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 16/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"
#import "TrackInfoViewController.h"
#import "TTCounterLabel.h"

@interface StartViewController : UIViewController <TTCounterLabelDelegate,MPMediaPickerControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
{
    MPMusicPlayerController *musicPlayer;
    
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIButton *btnFinish;
    IBOutlet UILabel *lapTime;
    IBOutlet UILabel *distanceLabel;
    
    IBOutlet UILabel *lapsLabel;
    IBOutlet UIButton *startBtn;
    
    IBOutlet UILabel *motionActivityIndicator;

    NSTimer *timer;
    
    NSDate *startDate;
    NSDate *lapDate;
    NSDate *lastLapDate;
    NSDate *sectorDate;
    NSTimeInterval secondsAlreadyRun;
    NSInteger lapCounter;
    
    IBOutlet MKMapView *mv;
    
    int runIndex;
    int sector1Count;
    int sector2Count;
    
    NSMutableDictionary *runLaps;
    NSString *sector1Time;
    NSString *sector2Time;
    NSString *sector3Time;
    NSString *recordedlapTime;
    NSString *totalRunTime;
    
    NSMutableDictionary *newRunAchievements;
    NSArray *currentAchievements;
    
    double totalPointsDistance;
    
    AppDelegate *appDelegate;
    
    CLLocation *sector1EndPoint;
    CLLocation *sector2EndPoint;
    
    CMMotionActivityManager *cmActivityMgr;
    CMStepCounter *cmStepCounter;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;
@property (nonatomic, strong) NSMutableArray *trackPointArray;
@property (nonatomic, strong) NSMutableArray *trackSectorPointArray;
@property (nonatomic, strong) NSMutableArray *runPointArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite) MKMapRect routeRect;
@property (nonatomic, strong) NSNumber *timeDuration;

- (IBAction)unwindToRunStart:(UIStoryboardSegue *)unwindSegue;
@end
