//
//  ProfileViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *tracksArray;
    NSMutableArray *trackRunsArray;
    NSMutableArray *runs;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
