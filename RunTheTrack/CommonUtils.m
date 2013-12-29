//
//  CommonUtils.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 29/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

+ (NSString *)timeFormattedStringForValue:(int)hrs :(int)mins :(int)secs {
//    int msperhour = 3600000;
//    int mspermin = 60000;
//    
//    int hrs = value / msperhour;
//    int mins = (value % msperhour) / mspermin;
//    int secs = ((value % msperhour) % mspermin) / 1000;
//    int frac = value % 1000 / 10;
    int frac = 0;
    
    NSString *formattedString = @"";
    
    if (hrs == 0) {
        if (mins == 0) {
            formattedString = [NSString stringWithFormat:@"%02ds.%02d", secs, frac];
        } else {
            formattedString = [NSString stringWithFormat:@"%02dm %02ds.%02d", mins, secs, frac];
        }
    } else {
        formattedString = [NSString stringWithFormat:@"%02dh %02dm %02ds.%02d", hrs, mins, secs, frac];
    }
    
    return formattedString;
}


@end
