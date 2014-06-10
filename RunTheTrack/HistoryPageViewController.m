//
//  HistoryPageViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 08/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "HistoryPageViewController.h"
#import "RunDetailViewController.h"
#import "RunOverviewViewController.h"
#import "RunTrackMapViewController.h"

@interface HistoryPageViewController ()
{
    RunOverviewViewController *controller1;
    RunTrackMapViewController *controller2;
    RunDetailViewController *controller3;
}
@end

@implementation HistoryPageViewController

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
    // Do any additional setup after loading the view.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    controller1 = (RunOverviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RunOverview"];
    controller2 = (RunTrackMapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RunTrack"];
    controller3 = (RunDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RunDetail"];
    controller1.runData = self.runData;
    controller1.managedObjectContext = self.managedObjectContext;
    controller2.runData = self.runData;
    controller2.managedObjectContext = self.managedObjectContext;
    controller3.runData = self.runData;
    controller3.managedObjectContext = self.managedObjectContext;
    
    NSArray *viewControllers = [NSArray arrayWithObjects:controller1, nil];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    pageControl.backgroundColor = [UIColor orangeColor];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.viewControllers[0] == controller3)
        return controller1;
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.viewControllers[0] == controller1)
        return controller3;
    return nil;
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
