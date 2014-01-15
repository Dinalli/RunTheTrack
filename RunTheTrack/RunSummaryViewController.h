//
//  RunSummaryViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryBaseViewController.h"

@interface RunSummaryViewController : UIPageViewController <UIPageViewControllerDataSource>
{
    NSArray *viewControllers;
}

@property (nonatomic,strong) RunData *runData;

@end
