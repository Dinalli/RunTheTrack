//
//  ProfileCollectionCell.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileCollectionCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileCollectionCell



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpOnLoad];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setUpOnLoad];
    }
    return self;
}

-(void)setUpOnLoad
{

        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        [self setAlpha:0.1];
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 4;
        [self.layer setMasksToBounds:YES];
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
