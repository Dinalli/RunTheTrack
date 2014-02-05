//
//  SectorTicker.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 04/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "SectorTicker.h"

@implementation SectorTicker

-(void)start
{
    count=0;
    numberOfObjects=[self. sectorDelegate numberOfRowsintickerView:self];
    
    [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveObjects) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkPosition) userInfo:nil repeats:YES];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor]CGColor], (id)[[UIColor blackColor]CGColor], nil];
    [self.layer addSublayer:gradient];
}


-(void)addElement:(UIView*)subView
{
    if (![self.subviews containsObject:(id)subView]) {
        [subView setFrame:CGRectMake(self.frame.size.width, 0, subView.frame.size.width, subView.frame.size.height)];
        [self addSubview:subView];
    }
}

-(void)checkPosition
{
    UIView *view=[self.sectorDelegate tickerView:self cellForRowAtIndex:count];
    CGRect rect=[view frame];
    float x=rect.origin.x+rect.size.width;
    if (x<300) {
        count=count+1;
        if (count==numberOfObjects) {
            count=0;
        }
    }
    UIView *subView=[self.sectorDelegate tickerView:self cellForRowAtIndex:count];
    [self addElement:subView];
    if ((rect.origin.x+rect.size.width)<0) {
        [view removeFromSuperview];
    }
}

-(void)moveObjects
{
    CGRect rect;
    for (UIView *view in self.subviews) {
        rect=[view frame];
        rect.origin.x=rect.origin.x-0.1;
        [view setFrame:rect];
        [view setNeedsDisplayInRect:rect];
    }
}

@end



