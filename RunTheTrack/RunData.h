//
//  RunData.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunAchievement, RunAltitude, RunLocations, RunSectors;

@interface RunData : NSManagedObject

@property (nonatomic, retain) NSString * rundate;
@property (nonatomic, retain) NSString * rundistance;
@property (nonatomic, retain) NSString * runid;
@property (nonatomic, retain) NSString * runlaps;
@property (nonatomic, retain) NSString * runPace;
@property (nonatomic, retain) NSString * runtime;
@property (nonatomic, retain) NSString * runtrackname;
@property (nonatomic, retain) NSSet *runAchievement;
@property (nonatomic, retain) NSSet *runDataLocations;
@property (nonatomic, retain) NSSet *runSectors;
@property (nonatomic, retain) NSSet *runAltitudes;
@end

@interface RunData (CoreDataGeneratedAccessors)

- (void)addRunAchievementObject:(RunAchievement *)value;
- (void)removeRunAchievementObject:(RunAchievement *)value;
- (void)addRunAchievement:(NSSet *)values;
- (void)removeRunAchievement:(NSSet *)values;

- (void)addRunDataLocationsObject:(RunLocations *)value;
- (void)removeRunDataLocationsObject:(RunLocations *)value;
- (void)addRunDataLocations:(NSSet *)values;
- (void)removeRunDataLocations:(NSSet *)values;

- (void)addRunSectorsObject:(RunSectors *)value;
- (void)removeRunSectorsObject:(RunSectors *)value;
- (void)addRunSectors:(NSSet *)values;
- (void)removeRunSectors:(NSSet *)values;

- (void)addRunAltitudesObject:(RunAltitude *)value;
- (void)removeRunAltitudesObject:(RunAltitude *)value;
- (void)addRunAltitudes:(NSSet *)values;
- (void)removeRunAltitudes:(NSSet *)values;

@end
