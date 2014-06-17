//
//  RunGraphViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 15/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBLineChartView.h"
#import "RunData.h"

@interface RunGraphViewController : RTTBaseViewController <JBLineChartViewDataSource, JBLineChartViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) RunData *runData;

@end
