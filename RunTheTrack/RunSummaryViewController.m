//
//  RunSummaryViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunSummaryViewController.h"
#import "RunAltitudeViewController.h"
#import "RunTrackMapViewController.h"
#import "RunOverviewViewController.h"
#import "RunDetailViewController.h"

@interface RunSummaryViewController ()

@end

@implementation RunSummaryViewController

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
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    viewControllers = @[@"RunOverview",@"RunTrack",@"RunDetail"];
    
    self.dataSource = self;

    HistoryBaseViewController *hbc = (HistoryBaseViewController *)[self.storyboard instantiateViewControllerWithIdentifier:[viewControllers objectAtIndex:0]];
    hbc.runData = self.runData;
    [self setViewControllers:@[hbc]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:NULL];
    
}

- (HistoryBaseViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    HistoryBaseViewController *hbvc = [self.storyboard instantiateViewControllerWithIdentifier:[viewControllers objectAtIndex:index]];
    hbvc.pageIndex = index;
    hbvc.runData = self.runData;
    
    return hbvc;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [viewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((HistoryBaseViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((HistoryBaseViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [viewControllers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
