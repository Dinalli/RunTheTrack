//
//  LapAnnotation.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 22/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end