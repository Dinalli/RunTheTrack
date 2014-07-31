//
//  RunChartViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 28/07/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunData.h"

@interface RunChartViewController : RTTBaseViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) RunData *runData;

@end
