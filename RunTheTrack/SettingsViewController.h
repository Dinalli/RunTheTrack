//
//  SettingsViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 06/11/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SettingsViewController : UIViewController <UIActionSheetDelegate>
{
    IBOutlet UIButton *signInButton;
    IBOutlet UILabel *userName;
}

@end
