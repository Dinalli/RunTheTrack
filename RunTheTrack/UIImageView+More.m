//
//  UIImageView+More.m
//  EventManage
//
//  Created by Cristian Ronaldo on 8/8/13.
//  Copyright (c) 2013 Cristian Ronaldo. All rights reserved.
//

#import "UIImageView+More.h"
#import "Global.h"

@implementation UIImageView(More)


- (void) setImageWithOptions:(NSString *)imgfileName options:(ImageOptionUnit)options use568h:(BOOL)use568h
{
    NSString * strImage = [self getRealImageFileName:imgfileName options:options use568h:use568h];
    [self setImage:[UIImage imageNamed:strImage]];
}


- (void) setResizableImageWithOptions:(NSString *)imgfileName
                              options:(ImageOptionUnit)options
                              use568h:(BOOL)use568h
                            capInsets:(UIEdgeInsets)capInsets
{
    NSString * strImage = [self getRealImageFileName:imgfileName options:options use568h:use568h];
    
    [self setImage:[[UIImage imageNamed:strImage] resizableImageWithCapInsets:capInsets]];
}


- (NSString *) getRealImageFileName:(NSString *)imgfileName options:(ImageOptionUnit)options use568h:(BOOL)use568h
{
    NSString * strDeviceName = @"";
    NSString * strOrientation= @"";
    NSString * strDisplayRetina = @"";
    
    NSString * strImage = @"";
    
    switch (options) {
        case IMAGE_OPTION_NONE:
            strImage = imgfileName;
            break;
            
        case IMAGE_OPTION_DEVICE:
            if (gDeviceType == DEVICE_IPAD) {
                strDeviceName = @"~ipad";
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH) {
                if ( use568h ) {
                    strOrientation = @"-568h";
                }
            }
            
            strImage = [NSString stringWithFormat:@"%@%@%@", imgfileName, strOrientation, strDeviceName];
            break;
            
        case IMAGE_OPTION_ORIENTATION:
            if (UIInterfaceOrientationIsPortrait(gDeviceOrientation)) {
                strOrientation = @"-Portrait";
            }
            else {
                strOrientation = @"-Landscape";
            }
            strImage = [NSString stringWithFormat:@"%@%@", imgfileName, strOrientation];
            break;
            
        case IMAGE_OPTION_RETINA:
            strDisplayRetina = @"@2x";
            strImage = [NSString stringWithFormat:@"%@%@", imgfileName, strDisplayRetina];
            break;
            
        case IMAGE_OPTION_DEVICE | IMAGE_OPTION_ORIENTATION :
            if (gDeviceType == DEVICE_IPAD) {
                strDeviceName = @"~ipad";
                
                if (UIInterfaceOrientationIsPortrait(gDeviceOrientation)) {
                    strOrientation = @"-Portrait";
                }
                else {
                    strOrientation = @"-Landscape";
                }
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH) {
                if ( use568h ) {
                    strOrientation = @"-568h";
                }
            }
            
            strImage = [NSString stringWithFormat:@"%@%@%@", imgfileName, strOrientation, strDeviceName];
            break;
            
        case IMAGE_OPTION_DEVICE | IMAGE_OPTION_RETINA :
            if (gDeviceType == DEVICE_IPAD) {
                strDeviceName = @"~ipad";
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH) {
                if ( use568h ) {
                    strOrientation = @"-568h";
                }
            }
            strDisplayRetina = @"@2x";
            
            strImage = [NSString stringWithFormat:@"%@%@%@%@", imgfileName, strOrientation, strDisplayRetina, strDeviceName];
            break;
            
        case IMAGE_OPTION_RETINA | IMAGE_OPTION_ORIENTATION :
            strDisplayRetina = @"@2x";
            
            if (UIInterfaceOrientationIsPortrait(gDeviceOrientation)) {
                strOrientation = @"-Portrait";
            }
            else {
                strOrientation = @"-Landscape";
            }
            
            strImage = [NSString stringWithFormat:@"%@%@%@", imgfileName, strOrientation, strDisplayRetina];
            break;
            
        case IMAGE_OPTION_DEVICE | IMAGE_OPTION_ORIENTATION | IMAGE_OPTION_RETINA :
            if (gDeviceType == DEVICE_IPAD) {
                strDeviceName = @"~ipad";
                
                if (UIInterfaceOrientationIsPortrait(gDeviceOrientation)) {
                    strOrientation = @"-Portrait";
                }
                else {
                    strOrientation = @"-Landscape";
                }
            }
            else if (gDeviceType == DEVICE_IPHONE_40INCH) {
                if ( use568h ) {
                    strOrientation = @"-568h";
                }
            }
            
            strDisplayRetina = @"@2x";
            strImage = [NSString stringWithFormat:@"%@%@%@%@", imgfileName, strOrientation, strDisplayRetina, strDeviceName];
            break;
    }
    
    return strImage;
}


@end
