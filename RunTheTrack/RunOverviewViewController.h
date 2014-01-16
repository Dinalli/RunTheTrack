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

@interface RunOverviewViewController : HistoryBaseViewController
{
    IBOutlet UIView *timeView;
    IBOutlet UIView *trackInfoView;
    IBOutlet UIView *runDetailsView;
    IBOutlet UIImageView *backgroundImageView;
}

@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatWithIndicator;

- (void)initFlatWithIndicatorProgressBar;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
