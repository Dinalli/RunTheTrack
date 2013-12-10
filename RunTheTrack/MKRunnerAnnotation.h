//
//  MKRunnerAnnotationView.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 01/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKRunnerAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end