//
//  RunAchievement.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 17/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunData;

@interface RunAchievement : NSManagedObject

@property (nonatomic, retain) NSString * achievementText;
@property (nonatomic, retain) NSString * achievementTrigger;
@property (nonatomic, retain) NSString * runId;
@property (nonatomic, retain) NSString * trackname;
@property (nonatomic, retain) RunData *relationship;

@end
