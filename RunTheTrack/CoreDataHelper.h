//
//  CoreDataHelper.h
//  Maverix
//
//  Created by Andrew Donnelly on 17/07/2010.
//  Copyright 2010 fifty50mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject {
	
}
+(NSUInteger) countObjectsInContextWithEntityName: (NSString*) entityName andPredicate: (NSPredicate *) predicate  withManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+(NSMutableArray *) getObjectsFromContextWithEntityName: (NSString*)entityName andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+(NSMutableArray *) searchObjectsInContextWithEntityName: (NSString*) entityName andPredicate: (NSPredicate *) predicate withSortKey: (NSString*) sortKey sortAscending: (BOOL) sortAscending withManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (BOOL) saveManagedObjectContext:(NSManagedObjectContext *)moc;
@end

