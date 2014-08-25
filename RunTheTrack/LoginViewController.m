//
//  LoginViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 10/07/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController
{
    IBOutlet UILabel *promptLabel;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *passwordLabel;
    IBOutlet UIButton *LoginButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *createUser;
    IBOutlet UIButton *logincreateUser;
    IBOutlet UITextField *loginName;
    IBOutlet UITextField *loginPassword;
    IBOutlet UIView *loginView;
    BOOL parseLogin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self setLoggedInFields];
    }
    else
    {
        [self setLoggedOutFields];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    parseLogin = YES;
}

-(void)setLoggedInFields
{
    [LoginButton setTitle:@"Logout" forState:UIControlStateNormal];
    [LoginButton setTag:99];
    [loginName setHidden:YES];
    [loginPassword setHidden:YES];
    [twitterButton setHidden:YES];
    [facebookButton setHidden:YES];
    [createUser setHidden:YES];
    [promptLabel setHidden:YES];
    [userNameLabel setHidden:YES];
    [passwordLabel setHidden:YES];
    [loginView setHidden:YES];
}

-(void)setLoggedOutFields
{
    [LoginButton setTitle:@"Login" forState:UIControlStateNormal];
    [LoginButton setTag:0];
    [loginName setHidden:NO];
    [loginPassword setHidden:NO];
    [twitterButton setHidden:NO];
    [facebookButton setHidden:NO];
    [createUser setHidden:NO];
    [promptLabel setHidden:NO];
    [userNameLabel setHidden:NO];
    [passwordLabel setHidden:NO];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    return YES;
}

-(PFUser *)createPFUser
{
    // New user
    PFUser *user = [PFUser user];
    user.username = loginName.text;
    user.password = loginPassword.text;
    return user;
}

-(IBAction)createAccountTapped:(id)sender
{
    [loginView setHidden:NO];
    [logincreateUser setTitle:@"Create Account & Login" forState:UIControlStateNormal];
}

-(IBAction)loginWithAccountTapped:(id)sender
{
    if(LoginButton.tag == 99)
    {
        [self loginWithParse];
        return;
    }
    
    [loginView setHidden:NO];
    [logincreateUser setTitle:@"Login" forState:UIControlStateNormal];
}

-(IBAction)loginCreateParse:(id)sender
{
    if(parseLogin)
    {
        [self loginWithParse];
    }
    else
    {
        [self createNewParseAccount];
    }
}

-(void)createNewParseAccount
{
    // create
    PFUser *user = [self createPFUser];
    [self createActivityIndicator];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your Login has been created." type:MessageBarMessageTypeInfo];
            
            loginPassword.text = @"";
            loginName.text = @"";
            [self setLoggedInFields];
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Login Error" description:errorString type:MessageBarMessageTypeError];
        }
        [self removeActivityIndicator];
    }];
}

-(void)loginWithParse
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        [PFUser logOut];
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have been logged out." type:MessageBarMessageTypeInfo];
        [self setLoggedOutFields];
    }
    else
    {
        // Login
        [self createActivityIndicator];
        [PFUser logInWithUsernameInBackground:loginName.text password:loginPassword.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                                [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
                                                [self setLoggedInFields];
                                                
                                            } else {
                                                // The login failed. Check error to see why.
                                                [[MessageBarManager sharedInstance] showMessageWithTitle:@"Login Error" description:error.localizedDescription type:MessageBarMessageTypeError];
                                            }
                                            [self removeActivityIndicator];
                                        }];
    }
}

-(IBAction)loginFacebook:(id)sender
{
    [self createActivityIndicator];
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            if (![PFFacebookUtils isLinkedWithUser:user]) {
                [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Woohoo, user logged in with Facebook!");
                        [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
                        
                        [self setLoggedInFields];
                    }
                }];
            }
            
            NSLog(@"User signed up and logged in through Facebook!");
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
        } else {
            NSLog(@"User logged in through Facebook!");
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
            [self setLoggedInFields];
        }
        
        [self removeActivityIndicator];
    }];
}

-(IBAction)loginTwitter:(id)sender
{
    [self createActivityIndicator];
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login. %@ %@", error.localizedDescription, error.debugDescription);
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
            if (![PFTwitterUtils isLinkedWithUser:user]) {
                [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
                    if ([PFTwitterUtils isLinkedWithUser:user]) {
                        NSLog(@"Woohoo, user logged in with Twitter!");
                        [self setLoggedInFields];
                    }
                }];
            }
        } else {
            NSLog(@"User logged in with Twitter!");
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your have logged in." type:MessageBarMessageTypeInfo];
            [self setLoggedInFields];
        }
        
        [self removeActivityIndicator];
    }];

}
@end
