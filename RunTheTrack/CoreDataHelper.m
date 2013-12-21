//
//  CoreDataHelper.m
//  Maverix
//
//  Created by Andrew Donnelly on 17/07/2010.
//  Copyright 2010 fifty50mobile. All rights reserved.
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper


+(NSUInteger) countObjectsInContextWithEntityName: (NSString*) entityName andPredicate: (NSPredicate *) predicate  withManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// If a predicate was passed, pass it to the query
	if(predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
	NSError *error;
	
    return [managedObjectContext countForFetchRequest:request error:&error];
}


+(NSMutableArray *) searchObjectsInContextWithEntityName: (NSString*) entityName andPredicate: (NSPredicate *) predicate withSortKey: (NSString*) sortKey sortAscending: (BOOL) sortAscending withManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// If a predicate was passed, pass it to the query
	if(predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
	// If a sort key was passed, use it for sorting.
	if(sortKey != nil)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	
	return mutableFetchResults;
}


+(NSMutableArray *) getObjectsFromContextWithEntityName: (NSString*)entityName andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsInContextWithEntityName:entityName andPredicate:nil withSortKey:nil sortAscending:YES withManagedObjectContext:managedObjectContext];
}

+ (BOOL) saveManagedObjectContext:(NSManagedObjectContext *)moc
{
	NSError *error = nil;
	if (![moc save:&error]) {
		// Save failed @@@: add your own error handling
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Data Save Failure" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [errorAlertView show];
		return NO;
	}
	return YES;
}


@end

