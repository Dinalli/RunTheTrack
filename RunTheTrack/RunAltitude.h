//
//  RunAltitude.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 17/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunData;

@interface RunAltitude : NSManagedObject

@property (nonatomic, retain) NSString * altitude;
@property (nonatomic, retain) NSString * altitudeTimeStamp;
@property (nonatomic, retain) NSString * runid;
@property (nonatomic, retain) RunData *runAlt;

@end
