//
//  SectorTickerView.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 04/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "SectorTickerView.h"

@implementation SectorTickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andLap:(NSString *)lap andSector:(NSString *)sector andTime:(NSString *)sectorTime andPurpleSector:(BOOL)purpleSector
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpViewWithLap:lap andSector:sector andTime:sectorTime andPurpler:purpleSector];
    }
    return self;
}

-(void)setUpViewWithLap:(NSString *)lap andSector:(NSString *)sector andTime:(NSString *)sectorTime andPurpler:(BOOL)purpleSector
{
    // add black gradient background
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor]CGColor], (id)[[UIColor blackColor]CGColor], nil];
    [self.layer addSublayer:gradient];
    
    // add yellow lap number
    UILabel *lapLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 25, 20)];
    lapLabel.text = lap;
    
    // add sector Number
    UILabel *sectorNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 2, 25, 20)];
    sectorNumberLabel.text = sector;
    
    // add time
    UILabel *sectorTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 100, 20)];
    sectorTimeLabel.text = lap;
    
    [self addSubview:lapLabel];
    [self addSubview:sectorNumberLabel];
    [self addSubview:sectorTimeLabel];
    
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
