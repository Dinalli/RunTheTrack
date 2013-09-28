//
//  RTTTrackInfoView.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 22/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTTTrackInfoView : UIView
{
    UILabel *trackLabel;
    UILabel *trackDistanceLabel;
    UILabel *trackLapsLabel;
    UIImageView *trackMapImageView;
    UIImageView *backgroundImage;
}

@property (nonatomic) UIImage *backImage;
@property (nonatomic) NSString *trackName;
@property (nonatomic) UIImage *trackMap;
@property (nonatomic) NSString *trackLaps;
@property (nonatomic) NSString *trackDistance;

@end
