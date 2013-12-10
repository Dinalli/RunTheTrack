//
//  ProfileHeaderView.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 27/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpOnLoad];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setUpOnLoad];
    }
    return self;
}

-(void)setUpOnLoad
{
    [self setAlpha:0.3];
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 4;
    [self.layer setMasksToBounds:YES];
    
    for (NSObject *obj in [self.profilePictureView subviews]) {
        if ([obj isMemberOfClass:[UIImageView class]]) {
            UIImageView *objImg = (UIImageView *)obj;
            objImg.image = [UIImage imageNamed:@"search-icon-main"];
            [self.profilePictureView setRoundedCornersWithRadius:44
                                                                     borderWidth:0
                                                                     borderColor:[UIColor clearColor]];
            break;
        }
    }
    
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

#pragma mark Facebook SignIn

-(IBAction)facebookSignIn:(id)sender
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
                 userName.text = user.name;
                 self.profilePictureView.profileID = user.id;
                 facebookLoginBtn.titleLabel.text = @"Logout Facebook";
             }
             
             if (error) {
                 for (NSObject *obj in [self.profilePictureView subviews]) {
                     if ([obj isMemberOfClass:[UIImageView class]]) {
                         UIImageView *objImg = (UIImageView *)obj;
                         objImg.image = [UIImage imageNamed:@"search-icon-main"];
                         break;
                     }
                 }
                CLS_LOG(@"facebook populateUserDetails %@", error.localizedDescription);
            }
         }];
    }
}

#pragma mark Twitter Sign In

-(IBAction)twitterSignIn:(id)sender
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
                    userName.text = twitterAccount.username;
                    twitterLoginBtn.titleLabel.text = @"Logout Twitter";
                    for (NSObject *obj in [self.profilePictureView subviews]) {
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
