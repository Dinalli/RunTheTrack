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
    NSString *lapSectorString;
    if(![sector isEqualToString:@"0"])
    {
        lapSectorString = [NSString stringWithFormat:@"Lap %@ Sector %@ %@", lap, sector,sectorTime];
    }
    else
    {
        lapSectorString = [NSString stringWithFormat:@"Lap %@ Time %@", lap,sectorTime];
    }
    NSMutableAttributedString *textToDraw = [[NSMutableAttributedString alloc] initWithString:lapSectorString];
    
    NSRange allRange = NSMakeRange(0, textToDraw.length);
    NSRange lapRange = [[textToDraw string] rangeOfString:[NSString stringWithFormat:@"Lap %@", lap]];
    NSRange sectorNumberRange = [[textToDraw string] rangeOfString:[NSString stringWithFormat:@"Sector %@", sector]];
    
    [textToDraw beginEditing];
    [textToDraw addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]
                       range:allRange];
    
    [textToDraw addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:allRange];

    [textToDraw addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]
                       range:lapRange];
    
    [textToDraw addAttribute:NSForegroundColorAttributeName
                       value:[UIColor yellowColor]
                       range:lapRange];

    [textToDraw addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]
                       range:sectorNumberRange];
    
    [textToDraw addAttribute:NSForegroundColorAttributeName
                       value:[UIColor greenColor]
                       range:sectorNumberRange];
    
    if(sectorTime)
    {
        NSRange sectorTimeRange = [[textToDraw string] rangeOfString:sectorTime];
        
        [textToDraw addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]
                           range:sectorTimeRange];
        
        [textToDraw addAttribute:NSForegroundColorAttributeName
                           value:[UIColor cyanColor]
                           range:sectorTimeRange];
    }
    [textToDraw endEditing];

    UITextView *tvSector = [[UITextView alloc] initWithFrame:self.frame];
    [tvSector setBackgroundColor:[UIColor clearColor]];
    tvSector.attributedText = textToDraw;
    tvSector.editable = NO;
    tvSector.scrollEnabled = NO;
    tvSector.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:tvSector];
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
