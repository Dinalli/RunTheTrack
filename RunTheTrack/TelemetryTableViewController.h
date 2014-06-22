//
//  TelemetryTableViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 21/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RTTBaseViewController.h"
#import "AppDelegate.h"

@interface TelemetryTableViewController : RTTBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
