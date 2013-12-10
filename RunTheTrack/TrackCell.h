//
//  TrackCell.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackCell : UICollectionViewCell

@property (nonatomic, strong) NSMutableDictionary *trackInfo;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *trackName;

@end