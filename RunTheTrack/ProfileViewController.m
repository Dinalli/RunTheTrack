//
//  ProfileViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 26/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCollectionCell.h"
#import "ProfileHeaderView.h"
#import "CoreDataHelper.h"
#import "RunData.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    tracksArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    trackRunsArray = [[NSMutableArray alloc] initWithCapacity:tracksArray.count];
    
    self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    for (NSDictionary *track in tracksArray)
    {
        for(RunData *rd in runs)
        {
            if([[track objectForKey:@"Race"] isEqualToString:rd.runtrackname])
            {
                if(![trackRunsArray containsObject:track])
                {
                    [trackRunsArray addObject:track];
                }
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
         headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
        int laps = 0;
        float totalDistance;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm:ss.SS"];
        NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
        NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
        
        for (RunData *rd in runs) {
            laps = laps + [rd.runlaps intValue];
            totalDistance = totalDistance + [rd.rundistance floatValue];
            
            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
        }
        headerView.totalLaps.text = [NSString stringWithFormat:@"Laps :%d", laps];
        headerView.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance];
        
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
        headerView.totalTime.text = [df stringFromDate:totalRunTime];

        headerView.totalTracks.text = [NSString stringWithFormat:@"Tracks %d", (int)trackRunsArray.count];
    }
    
//    if (kind == UICollectionElementKindSectionFooter) {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//        
//        reusableview = footerview;
//    }
    
    return reusableview;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view
     numberOfItemsInSection:(NSInteger)section {
    return [trackRunsArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *TrackInfo = (NSMutableDictionary *)[trackRunsArray objectAtIndex:indexPath.row];
    
    ProfileCollectionCell *cell = [cv
                       dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionCell"
                       forIndexPath:indexPath];
    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
    cell.imageView.image = [UIImage imageNamed:[TrackInfo objectForKey:@"trackimage"]];
    
    int laps = 0;
    float totalDistance;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SS"];
    NSDate *totalRunTime = [df dateFromString:@"00:00:00.00"];
    NSDate *zeroRunTime = [df dateFromString:@"00:00:00.00"];
    
    for (RunData *rd in runs) {
        if([rd.runtrackname isEqualToString:cell.trackName.text])
        {
            laps = laps + [rd.runlaps intValue];
            totalDistance = totalDistance + [rd.rundistance floatValue];
            NSDate *runTimeDate = [df dateFromString:[NSString stringWithFormat:@"%@",rd.runtime]];
            NSTimeInterval interval = [runTimeDate timeIntervalSinceDate:zeroRunTime];
            totalRunTime = [totalRunTime dateByAddingTimeInterval:interval];
        }
    }
    
    cell.totalLaps.text = [NSString stringWithFormat:@"Laps :%d", laps];
    cell.totalDistance.text = [NSString stringWithFormat:@"%.02f miles", totalDistance];
    
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    cell.totalTime.text = [df stringFromDate:totalRunTime];
    
    return cell;
}

-(IBAction)showActivityView:(id)sender
{
    UIActionSheet *loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Login using" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"facebook" otherButtonTitles:@"twitter", nil];
    [loginActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self facebookSignIn];
    }
    else if (buttonIndex == 1) {
        [self twitterSignIn];
    }
}

-(void)setUpOnLoad
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
        [appDelegate openSession];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
}



-(void)facebookSignIn
{
    //Sign into facebook
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
    }
}

- (void)updateView {
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        //[signInButton setTitle:@"Log out" forState:UIControlStateNormal];
        [self populateUserDetails];
        
    } else {
        // login-needed account UI is shown whenever the session is closed
        //[signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
        [appDelegate.session closeAndClearTokenInformation];
        [self populateUserDetails];
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}

- (void)populateUserDetails
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [self.navigationItem setTitle:user.name];
                 headerView.profilePictureView.profileID = user.id;
             }
             
             if (error) {
                 CLS_LOG(@"facebook populateUserDetails %@", error.localizedDescription);
             }
         }];
    }
}

#pragma mark Twitter Sign In

-(void)twitterSignIn
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                //for (ACAccount *twitterAccount in accounts) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ACAccount *twitterAccount = [accounts objectAtIndex:0];

                    [self.navigationItem setTitle:twitterAccount.username];
                    for (NSObject *obj in [headerView.profilePictureView subviews]) {
                        if ([obj isMemberOfClass:[UIImageView class]]) {
                            UIImageView *objImg = (UIImageView *)obj;
                            objImg.image = [UIImage imageNamed:@"search-icon-main"];
                            break;
                        }
                    }
                });
                //}
            }
        }
        else if (error)
        {
            CLS_LOG(@"twitter login failed %@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
