//
//  RTTBaseViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 20/05/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RTTBaseViewController.h"

@interface RTTBaseViewController ()
{
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation RTTBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

#pragma mark - Activity Indicator

-(void)createActivityIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ( activityIndicator == nil)
    {
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.frame = CGRectMake(self.view.frame.size.width/2.0 - 25 , self.view.frame.size.height/2.0 - 25, 50, 50);
        activityIndicator.layer.cornerRadius = 8.0f;
        activityIndicator.layer.masksToBounds = YES;
        activityIndicator.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        [activityIndicator startAnimating];
        activityIndicator.hidden = NO;
        [self.view addSubview:activityIndicator];
    }
}

-(void)removeActivityIndicator;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
