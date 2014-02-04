//
//  RTTBaseAnnotation.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 03/02/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RTTBaseAnnotation : NSObject <MKAnnotation>

@property (nonatomic) NSString *trackName;
@property (nonatomic) NSString *lap;
@property (nonatomic) NSString *time;
@property (nonatomic) NSString *sectorNumber;
@property (nonatomic) NSString *sectorTime;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
