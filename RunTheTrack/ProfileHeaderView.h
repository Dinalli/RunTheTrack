//
//  ProfileHeaderView.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 27/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ProfileHeaderView : UICollectionReusableView
{
}

// typical outlet for the FBPriflePictureView
@property (retain, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (retain, nonatomic) IBOutlet UILabel *totalLaps;
@property (retain, nonatomic) IBOutlet UILabel *totalDistance;
@property (retain, nonatomic) IBOutlet UILabel *totalTime;
@property (retain, nonatomic) IBOutlet UILabel *totalTracks;

@end
