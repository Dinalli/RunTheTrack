//
//  JBBaseViewController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/7/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBaseViewController.h"

#define kJBImageIconJawboneLogo @"icon-jawbone-logo.png"
#define kJBImageIconArrow @"icon-arrow.png"
#define kJBImageIconLineChart @"icon-line-chart.png"
#define kJBImageIconBarChart @"icon-bar-chart.png"

@interface JBBaseViewController ()

@end

@implementation JBBaseViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Getters

- (UIBarButtonItem *)chartToggleButtonWithTarget:(id)target action:(SEL)action
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kJBImageIconArrow] style:UIBarButtonItemStylePlain target:target action:action];
    return button;
}

@end
