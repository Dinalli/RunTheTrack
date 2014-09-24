//
//  AppDelegate.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 19/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MessageBarManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <iAd/iAd.h>
#import "RunData.h"
#import <Parse/Parse.h>

extern NSString *const SCSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *tracksArray;

@property (nonatomic) BOOL useMotion;
@property (nonatomic) CGFloat runMotionDistance;
@property (nonatomic) BOOL useKMasUnits;
@property (nonatomic) BOOL musicIsPlaying;

@property (nonatomic) BOOL soundEnabled;

@property (nonatomic) RunData *selectedRun;

- (void)openSession;

@end
