//
//  Sector1Annotaion.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 15/12/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Sector1Annotaion : NSObject <MKAnnotation>
    
    @property (nonatomic, strong) NSString *imageName;
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
