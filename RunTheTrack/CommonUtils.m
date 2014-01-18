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


+(NSString *)formattedStringFromDate:(NSDate *)dateIn
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MMM/yyyy HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    return [dateFormatter stringFromDate:dateIn];
}


+ (void)shadowAndRoundView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0,-3);
    view.layer.shadowRadius = 2;
    view.layer.shadowOpacity = 0.7;
    view.layer.cornerRadius = 4;
    view.layer.borderColor = [[UIColor blackColor] CGColor];
    view.layer.borderWidth = 0.5;
}

+ (void)addMotionEffectToView:(UIView *)view
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [view addMotionEffect:group];
}

@end
