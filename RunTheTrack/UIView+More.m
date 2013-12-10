//
//  UIView+More.m
//  MansionEscape
//
//  Created by Cristian Ronaldo on 9/16/13.
//  Copyright (c) 2013 Cristian Ronaldo. All rights reserved.
//

#import "UIView+More.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView(More)

- (void) setRoundedCornersWithRadius:(float)radius
                         borderWidth:(float)borderWidth
                         borderColor:(UIColor *)borderColor
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = borderColor.CGColor;
}

@end
