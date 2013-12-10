//
//  AchivementsCollectionViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchivementsCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *runAchivements;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *runId;

@end
