//
//  ProfileViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "ProfileHeaderView.h"

@interface ProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>
{
    NSArray *tracksArray;
    NSMutableArray *trackRunsArray;
    NSMutableArray *runs;
    ProfileHeaderView *headerView;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
