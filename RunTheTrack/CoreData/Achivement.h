//
//  Achivement.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 21/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Achivement : NSManagedObject

@property (nonatomic, retain) NSString * achivementtext;
@property (nonatomic, retain) NSString * trigger;

@end
