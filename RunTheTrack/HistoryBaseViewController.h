//
//  HistoryBaseViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunData.h"
#import <Social/Social.h>

@interface HistoryBaseViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic,strong) RunData *runData;
@property NSUInteger pageIndex;

@end
