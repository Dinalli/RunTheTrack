//
//  RTTBaseViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 20/05/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "AppDelegate.h"

@interface RTTBaseViewController : UIViewController

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)createActivityIndicator;
-(void)removeActivityIndicator;

@end
