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
#import "AppDelegate.h"
#import "TrackInfoViewController.h"
#import "TTCounterLabel.h"

@interface StartViewController : UIViewController <TTCounterLabelDelegate,MPMediaPickerControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
{
    MPMusicPlayerController *musicPlayer;
    
    IBOutlet UILabel *currentTrack;
    //IBOutlet TTCounterLabel *timeLabel;
    
    IBOutlet UILabel *lapTime;
    IBOutlet UILabel *distanceLabel;
    
    IBOutlet UILabel *lapsLabel;
    IBOutlet UILabel *trackNameLabel;
    
    
    IBOutlet UIButton *startBtn;
    IBOutlet UIButton *finishBtn;
    
    IBOutlet UIButton *trackBtn;
    
    IBOutlet UIView *runControlView;
    
    IBOutlet UIImageView *trackImage;
    
    IBOutlet UISegmentedControl *intervalSeg;
    IBOutlet UISegmentedControl *runTypeSeg;
    IBOutlet UISegmentedControl *distanceUnit;
    
    IBOutlet UILabel *drsLabel;
    IBOutlet UIImageView *gpsIcon;
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
    
    double totalDistance;
    
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSTimer *gpsTimer;

@property (nonatomic) NSMutableDictionary *trackInfo;


@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;
@property (nonatomic, strong) NSMutableArray *trackPointArray;
@property (nonatomic, strong) NSMutableArray *runPointArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite) MKMapRect routeRect;
@property (nonatomic, strong) NSNumber *timeDuration;

- (IBAction)trackChosen:(UIStoryboardSegue *)segue;

- (IBAction)unwindToRunStart:(UIStoryboardSegue *)unwindSegue;
@end
