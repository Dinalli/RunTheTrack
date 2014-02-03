//
//  TimeCalloutView.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 03/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "TimeCalloutView.h"

@implementation TimeCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpView];
    }
    return self;
}

-(void)setUpView
{
    self.trackName = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width, 24)];
    [self.trackName setBackgroundColor:[UIColor greenColor]];
    
    self.lap = [[UILabel alloc] initWithFrame:CGRectMake(2, 28, self.frame.size.width, 24)];
    [self.lap setBackgroundColor:[UIColor orangeColor]];
    
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(2, 52, self.frame.size.width, 24)];
    [self.time setBackgroundColor:[UIColor blueColor]];
    
    self.sectorNumber = [[UILabel alloc] initWithFrame:CGRectMake(2, 88, self.frame.size.width, 24)];
    [self.sectorNumber setBackgroundColor:[UIColor cyanColor]];
    
    
    [self addSubview:self.trackName];
    [self addSubview:self.lap];
    [self addSubview:self.time];
    [self addSubview:self.sectorNumber];
}

-(void)setTrackNameText:(NSString *)trackNameValue
{
    [self.trackName setText:trackNameValue];
}

-(void)setSectorText:(NSString *)sectorValue
{
    [self.sectorNumber setText:sectorValue];
}

-(void)setLapText:(NSString *)lapValue
{
    [self.lap setText:lapValue];
}

-(void)setTimeText:(NSString *)timeValue
{
    [self.time setText:timeValue];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
