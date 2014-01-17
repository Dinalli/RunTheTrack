//
//  CommonUtils.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 29/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+ (NSString *)timeFormattedStringForValue:(int)hrs :(int)mins :(int)secs;
+ (NSString *)formattedStringFromDate:(NSDate *)dateIn;

@end
