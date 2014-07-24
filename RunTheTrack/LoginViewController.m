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
    IBOutlet UIButton *LoginButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *createUser;
    IBOutlet UITextField *loginName;
    IBOutlet UITextField *loginPassword;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [LoginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
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

-(IBAction)createNewAccount:(id)sender
{
    // create
    PFUser *user = [self createPFUser];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Success" description:@"Your Login has been created." type:MessageBarMessageTypeInfo];
            
            loginPassword.text = @"";
            loginName.text = @"";
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [[MessageBarManager sharedInstance] showMessageWithTitle:@"Login Error" description:errorString type:MessageBarMessageTypeError];
        }
    }];
}

-(IBAction)loginParse:(id)sender
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        [PFUser logOut];
    }
    else
    {
        // Login
        [PFUser logInWithUsernameInBackground:loginName.text password:loginPassword.text
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                            } else {
                                                // The login failed. Check error to see why.
                                            }
                                        }];
    }
}

-(IBAction)loginFacebook:(id)sender
{
    [PFFacebookUtils logInWithPermissions:@[@"public_profile"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            if (![PFFacebookUtils isLinkedWithUser:user]) {
                [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Woohoo, user logged in with Facebook!");
                    }
                }];
            }
            
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];
}


-(IBAction)loginTwitter:(id)sender
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            if (![PFTwitterUtils isLinkedWithUser:user]) {
                [PFTwitterUtils linkUser:user block:^(BOOL succeeded, NSError *error) {
                    if ([PFTwitterUtils isLinkedWithUser:user]) {
                        NSLog(@"Woohoo, user logged in with Twitter!");
                    }
                }];
            }
        } else {
            NSLog(@"User logged in with Twitter!");
        }     
    }];
}
@end
