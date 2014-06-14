//
//  RunStatsViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunData.h"
#import "CorePlot-CocoaTouch.h"

@interface RunStatsViewController : RTTBaseViewController <CPTBarPlotDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) RunData *runData;

@end
