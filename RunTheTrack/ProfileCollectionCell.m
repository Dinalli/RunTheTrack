//
//  ProfileCollectionCell.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileCollectionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "YLProgressBar.h"

@implementation ProfileCollectionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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

@end
