//
//  RunGraphViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 15/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunGraphViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "RunAltitude.h"
#import "JBChartInformationView.h"
#import "JBChartTooltipView.h"


#define ARC4RANDOM_MAX 0x100000000

#define kJBColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kJBColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]

@interface RunGraphViewController ()
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
    NSMutableArray *altitudePoints;
    NSMutableArray *points;
    JBLineChartView *lineChartView;
}

@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong, readonly) JBChartTooltipView *tooltipView;


@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *daysOfWeek;

// Helpers
- (void)initFakeData;

@end

@implementation RunGraphViewController

CGFloat const kJBLineChartViewControllerChartHeight = 250.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 0.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 1.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 50;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self loadGraphData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self loadGraphData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self loadGraphData];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIScrollView *chartScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding, self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight)];
    
    self.view.backgroundColor = [UIColor redColor];
    lineChartView = [[JBLineChartView alloc] init];
    lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding, self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * points.count), kJBLineChartViewControllerChartHeight);
    lineChartView.delegate = self;
    lineChartView.dataSource = self;
    lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    lineChartView.backgroundColor = [UIColor lightGrayColor];
    
//    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeaderHeight)];
//    headerView.titleLabel.text = [kJBStringLabelAverageDailyRainfall uppercaseString];
//    headerView.titleLabel.textColor = kJBColorLineChartHeader;
//    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
//    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
//    headerView.subtitleLabel.text = kJBStringLabel2013;
//    headerView.subtitleLabel.textColor = kJBColorLineChartHeader;
//    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
//    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
//    headerView.separatorColor = kJBColorLineChartHeaderSeparatorColor;
//    lineChartView.headerView = headerView;
    
//    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
//    footerView.backgroundColor = [UIColor clearColor];
//    footerView.leftLabel.text = [[self.daysOfWeek firstObject] uppercaseString];
//    footerView.leftLabel.textColor = [UIColor whiteColor];
//    footerView.rightLabel.text = [[self.daysOfWeek lastObject] uppercaseString];;
//    footerView.rightLabel.textColor = [UIColor whiteColor];
//    footerView.sectionCount = [[self largestLineData] count];
//    lineChartView.footerView = footerView;
    
    [self.view addSubview:chartScroller];
    [chartScroller addSubview:lineChartView];
    [chartScroller setContentSize:lineChartView.frame.size];
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.informationView setTitleTextColor:[UIColor blackColor]];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:[UIColor orangeColor]];
    [self.view addSubview:self.informationView];
    
    [lineChartView reloadData];
}


- (void)initFakeData
{
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    for (int lineIndex=0; lineIndex<3; lineIndex++)
    {
        NSMutableArray *mutableChartData = [NSMutableArray array];
        for (int i=0; i<kJBLineChartViewControllerMaxNumChartPoints; i++)
        {
            [mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX)]]; // random number between 0 and 1
        }
        [mutableLineCharts addObject:mutableChartData];
    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
    _daysOfWeek = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [lineChartView setState:JBChartViewStateExpanded];
}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return points.count;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
//    NSLog(@"Points Count %d", points.count);
    return 1;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    NSLog(@"Vertical Value %@ Hor %d - Line Index %d", [points objectAtIndex:lineIndex], horizontalIndex, lineIndex);
    return [[points objectAtIndex:lineIndex] floatValue];// y-position (y-axis) of point at horizontalIndex (x-axis)
}

//- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
//{
//    NSLog(@"no lines %d", [self.chartData count]);
//    return [self.chartData count];
//}

//- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
//{
//    //NSLog(@"no vertical lines %d", [[self.chartData objectAtIndex:lineIndex] count]);
//    return [[self.chartData objectAtIndex:lineIndex] count];
//}
//
//- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
//{
//    //NSLog(@"vertical value %f", [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue]);
//    return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
//}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBColorLineChartDefaultSolidLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor cyanColor];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBLineChartViewControllerChartSolidLineWidth;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 5.0;
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor blueColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBColorLineChartDefaultSolidSelectedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor orangeColor];
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewLineStyleSolid;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == JBLineChartViewLineStyleSolid;
}

-(void)loadGraphData
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.runData = appDelegate.selectedRun;
    
    runs = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunData" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    runs = [[[runs reverseObjectEnumerator] allObjects] mutableCopy];
    
    if (runs.count == 0)
    {
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"No past runs available."
                                                     description:[NSString stringWithFormat:@"Why not go for a run. You will be able to see details of your past runs here."]
                                                            type:MessageBarMessageTypeInfo];
    }
    else{
        altitudePoints = [[self.runData.runAltitudes allObjects] mutableCopy];
    }
    NSMutableArray *xAxisLabels = [NSMutableArray new];
    points = [NSMutableArray array];
    for (NSInteger index = 0; index < altitudePoints.count; index++) {
        RunAltitude *runAltitude = (RunAltitude *)[altitudePoints objectAtIndex:index];
        [xAxisLabels addObject:runAltitude.altitudeTimeStamp];
        [points addObject:runAltitude.altitude];
    }
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [points objectAtIndex:horizontalIndex];
    [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"m"];
    [self.informationView setTitleText:@"Altitude"];
    //[self.informationView setTitleText:lineIndex == JBLineChartLineSolid ? kJBStringLabelMetropolitanAverage : kJBStringLabelNationalAverage];
    [self.informationView setHidden:NO animated:YES];
    //[self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[[self.daysOfWeek objectAtIndex:horizontalIndex] uppercaseString]];
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
