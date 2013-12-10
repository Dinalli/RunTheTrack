//
//  ProfileCollectionCell.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *trackName;
@property (retain, nonatomic) IBOutlet UILabel *totalLaps;
@property (retain, nonatomic) IBOutlet UILabel *totalDistance;
@property (retain, nonatomic) IBOutlet UILabel *totalTime;

@end
