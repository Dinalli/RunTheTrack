//
//  RunLocations.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 17/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunData;

@interface RunLocations : NSManagedObject

@property (nonatomic, retain) NSString * lattitude;
@property (nonatomic, retain) NSString * locationIndex;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * runid;
@property (nonatomic, retain) NSString * locationTimeStamp;
@property (nonatomic, retain) RunData *runLoactionsData;

@end
