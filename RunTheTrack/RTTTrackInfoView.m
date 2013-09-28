//
//  RTTTrackInfoView.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 22/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "RTTTrackInfoView.h"

@implementation RTTTrackInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

-(void)setUpView
{
    backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
    [self addSubview:backgroundImage];
    
    trackMapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.frame.size.height-180, 150, 150)];
    [self addSubview:trackMapImageView];
    
    trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 50, 320, 50)];
    [trackLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:56.0]];
    [trackLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:trackLabel];
    
    trackDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, self.frame.size.height-180, 80, 50)];
    [trackDistanceLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16.0]];
    [trackDistanceLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:trackDistanceLabel];
    
    trackLapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, self.frame.size.height-120, 80, 50)];
    [trackLapsLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16.0]];
    [trackLapsLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:trackLapsLabel];
}


-(void)setTrackDistance:(NSString *)trackDistance
{
    trackDistanceLabel.text = [NSString stringWithFormat:@"%@ miles", trackDistance];
}

-(void)setTrackLaps:(NSString *)trackLaps
{
    trackLapsLabel.text = [NSString stringWithFormat:@"%@ laps", trackLaps];;
}

-(void)setBackImage:(UIImage *)backImage
{
    backgroundImage.image = backImage;
}

-(void)setTrackName:(NSString *)trackName
{
    trackLabel.text = trackName;
}


-(void)setTrackMap:(UIImage *)trackMap
{
    trackMapImageView.image = trackMap;
}
@end
