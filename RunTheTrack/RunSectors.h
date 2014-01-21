//
//  RunSectors.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 21/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunData;

@interface RunSectors : NSManagedObject

@property (nonatomic, retain) NSString * lapLat;
@property (nonatomic, retain) NSString * lapLong;
@property (nonatomic, retain) NSString * lapNumber;
@property (nonatomic, retain) NSString * lapPace;
@property (nonatomic, retain) NSString * lapTime;
@property (nonatomic, retain) NSString * runId;
@property (nonatomic, retain) NSString * sector1Time;
@property (nonatomic, retain) NSString * sector2Time;
@property (nonatomic, retain) NSString * sector3Time;
@property (nonatomic, retain) NSString * sec1Lat;
@property (nonatomic, retain) NSString * sec1Long;
@property (nonatomic, retain) NSString * sec2Lat;
@property (nonatomic, retain) NSString * sec2Long;
@property (nonatomic, retain) RunData *relationship;

@end
