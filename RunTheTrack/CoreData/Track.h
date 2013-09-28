//
//  Track.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 21/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Track : NSManagedObject

@property (nonatomic, retain) NSString * laps;
@property (nonatomic, retain) NSString * trackdistance;
@property (nonatomic, retain) NSString * trackname;

@end
