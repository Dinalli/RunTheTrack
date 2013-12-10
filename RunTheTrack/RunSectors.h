//
//  RunSectors.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 17/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunData;

@interface RunSectors : NSManagedObject

@property (nonatomic, retain) NSString * runId;
@property (nonatomic, retain) NSString * lapNumber;
@property (nonatomic, retain) NSString * sector1Time;
@property (nonatomic, retain) NSString * sector3Time;
@property (nonatomic, retain) NSString * sector2Time;
@property (nonatomic, retain) NSString * lapTime;
@property (nonatomic, retain) RunData *relationship;

@end
