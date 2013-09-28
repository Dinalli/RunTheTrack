//
//  Progress.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 21/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Progress : NSManagedObject

@property (nonatomic, retain) NSString * distancecovered;
@property (nonatomic, retain) NSString * track;

@end
