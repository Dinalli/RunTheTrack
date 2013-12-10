//
//  RunSectorsViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 05/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunData.h"

@interface RunSectorsViewController : UITableViewController
{
    NSMutableArray *runLapsArray;
}

@property (nonatomic,strong) RunData *runData;

@end
