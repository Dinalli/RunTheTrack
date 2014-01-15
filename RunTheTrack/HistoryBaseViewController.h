//
//  HistoryBaseViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunData.h"

@interface HistoryBaseViewController : UIViewController

@property (nonatomic,strong) RunData *runData;
@property NSUInteger pageIndex;

@end
