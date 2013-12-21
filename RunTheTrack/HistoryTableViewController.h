//
//  HistoryTableViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 16/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface HistoryTableViewController : UITableViewController
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
