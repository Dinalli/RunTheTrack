//
//  RunMapViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryBaseViewController.h"
#import "YLProgressBar.h"
#import "AppDelegate.h"

@interface RunOverviewViewController : HistoryBaseViewController
{
    IBOutlet UIView *timeView;
    IBOutlet UIView *trackInfoView;
    IBOutlet UIView *runDetailsView;
    IBOutlet UIImageView *backgroundImageView;
    
    IBOutlet UILabel *runDistance;
    IBOutlet UILabel *runTime;
    IBOutlet UILabel *runDate;
    IBOutlet UILabel *runSteps;
    IBOutlet UILabel *runType;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runPace;
    IBOutlet UILabel *runClimb;
    
    IBOutlet UILabel *trackLaps;
    IBOutlet UILabel *trackName;
    IBOutlet UILabel *trackDistance;
    
}

@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatWithIndicator;

- (void)initFlatWithIndicatorProgressBar;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
