//
//  AppDelegate.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 19/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
@implementation AppDelegate

NSString *const SCSessionStateChangedNotification = @"com.facebook.Scrumptious:SCSessionStateChangedNotification";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    [Crashlytics startWithAPIKey:@"52f789dbfeee4af97bac9b49fd6414dc64175c2f"];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker.
    id<GAITracker> tracker __unused = [[GAI sharedInstance] trackerWithTrackingId:@"UA-47282955-1"];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"app_opened"  // Event action (required)
                                                           label:@"loaded"          // Event label
                                                           value:nil] build]];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    self.tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];

    self.useMotion = NO;
    self.musicIsPlaying = NO;
    
    [self setUpDefaultsOnLoad];
    
    //Cancel any Notificaitons we have set
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // Set up for using iAd
    [UIViewController prepareInterstitialAds];
    
    
    //Set Up for Parse
    [Parse setApplicationId:@"rVf0vPwhdrzKazUVEvYPGKVJBvfg1NH7WHuZRLvz"
                  clientKey:@"vVfm7AfjoC88w4UnSrVFrMaezEZ9twIxoj8wClkK"];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    [PFTwitterUtils initializeWithConsumerKey:@"7Rfb2ByqTzLNCuYkThQ2lGVGG"
                               consumerSecret:@"kzZzShf66wuTMLRRDlNxLeqXEP4MVHml023KBC5Kyi2K8mfmGo"];
    
    return YES;
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

-(void)setUpDefaultsOnLoad
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *units = [defaults objectForKey:@"units"];
    if(!units)
    {
        [self setUseKMasUnits:NO];
    }
    else
    {
        [self setUseKMasUnits:[units boolValue]];
    }
    
    self.useMotion = [[defaults valueForKey:@"motion"] boolValue];
    self.runMotionDistance = [[defaults valueForKey:@"runSliderValue"] floatValue];
}



#pragma mark Push Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        NSString *messageText;
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        messageText = [aps objectForKey:@"alert"];
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Alert"
                                                     description:messageText
                                                            type:MessageBarMessageTypeInfo];
    }
}


#pragma mark Login Facebook

-(NSDictionary*)splitQuery:(NSString*)query {
    if(!query||[query length]==0) return nil;
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    for(NSString* parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound)
            [parameters setValue:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        else [parameters setValue:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    }
    return parameters;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"URL OPEN %@", url);
    NSLog(@"URL Scheme %@", url.scheme);
    NSLog(@"URL CODE %@", [[self splitQuery:url.query] objectForKey:@"code"]);
    NSLog(@"Source Application %@", sourceApplication);
    
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    [FBSettings setDefaultAppID:@"636662449718679"];
    [FBAppEvents activateApp];
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Check application background refresh
    
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Background App Refresh Is Switched Off"
                                                     description:@"You will need to enable Background App Refresh to use this App."
                                                            type:MessageBarMessageTypeInfo];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            CLSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RTT" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RTT.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        CLSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
