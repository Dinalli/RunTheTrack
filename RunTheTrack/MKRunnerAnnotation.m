//
//  MKRunnerAnnotationView.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 01/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "MKRunnerAnnotation.h"

@implementation MKRunnerAnnotation


//- (CLLocationCoordinate2D)coordinate
//{
//    coordinate.latitude = [self.latitude doubleValue];
//    coordinate.longitude = [self.longitude doubleValue];
//    return coordinate;
//}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
//- (NSString *)title
//{
//    return @"Runner";
//}

// optional
- (NSString *)subtitle
{
    return @"Gonna put speed or something here";
}

@end
