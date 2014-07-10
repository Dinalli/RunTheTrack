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
#import "RunLocations.h"
#import "RunAltitude.h"


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
    NSMutableArray *graphPoints;
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

CGFloat const kJBLineChartViewControllerChartHeight = 350.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 0.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 175.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 1.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 200;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initFakeData];
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
        [self initFakeData];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIScrollView *chartScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPadding, self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight)];
    
    self.view.backgroundColor = [UIColor redColor];
    lineChartView = [[JBLineChartView alloc] init];
    lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, 60, self.view.bounds.size.width, 320);
    lineChartView.delegate = self;
    lineChartView.dataSource = self;
    lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    lineChartView.backgroundColor = [UIColor lightGrayColor];
    
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
    return [self.chartData count];
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:lineIndex] count]-1;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    float valueforpoint = 0.0f;
    valueforpoint = [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
    return valueforpoint;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    switch (lineIndex) {
        case 0:
            return [UIColor whiteColor];
            break;
        case 1:
            return [UIColor greenColor];
            break;
        case 2:
            return [UIColor orangeColor];
            break;
            
        default:
            break;
    }
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    switch (lineIndex) {
        case 0:
                return [UIColor yellowColor];
            break;
        case 1:
                return [UIColor cyanColor];
            break;
        case 2:
                return [UIColor blueColor];
            break;
            
        default:
            break;
    }
    return [UIColor redColor];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2.0f;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 4.0;
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor blueColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    switch (lineIndex) {
        case 0:
            return [UIColor yellowColor];
            break;
        case 1:
            return [UIColor cyanColor];
            break;
        case 2:
            return [UIColor blueColor];
            break;
            
        default:
            break;
    }
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
    CLLocationDistance totalDistance;
    RunLocations *oldLocation;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.runData = appDelegate.selectedRun;
    
    NSMutableArray *runLocationsArray = [[self.runData.runDataLocations allObjects] mutableCopy];
    [runLocationsArray sortUsingComparator:^NSComparisonResult(id a, id b) {
        RunLocations *aLoc = (RunLocations *)a;
        RunLocations *bLoc = (RunLocations *)b;
//        NSInteger firstInteger = [aRunSector.lapNumber integerValue];
//        NSInteger secondInteger = [bRunSector.lapNumber integerValue];
//        
//        if (firstInteger > secondInteger)
//            return NSOrderedDescending;
//        if (firstInteger < secondInteger)
//            return NSOrderedAscending;
        return [aLoc.locationIndex localizedCompare: bLoc.locationIndex];
    }];

    
    altitudePoints = [[self.runData.runAltitudes allObjects] mutableCopy];
    
    totalDistance = 0;
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    for (int lineIndex=0; lineIndex<3; lineIndex++)
    {
        NSMutableArray *mutableChartData = [NSMutableArray array];
        for (int i=0; i<kJBLineChartViewControllerMaxNumChartPoints; i++)
        {
            CLLocation *lastLocation;
            switch (lineIndex) {
                case 0:
                {
                    RunLocations *runLoc = [runLocationsArray objectAtIndex:i];
                    if(oldLocation)
                    {
                        lastLocation = [[CLLocation alloc] initWithLatitude:[oldLocation.lattitude doubleValue] longitude:[oldLocation.longitude doubleValue]];
                        
                        CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[runLoc.lattitude doubleValue] longitude:[runLoc.longitude doubleValue]];
                        CLLocationDistance distance = [nextLocation distanceFromLocation:lastLocation];
                        totalDistance = totalDistance + distance;
                        
                        if([appDelegate useKMasUnits])
                        {
                            [mutableChartData addObject:[NSString stringWithFormat:@"%.2f", totalDistance / 1000]];
                        }
                        else
                        {
                            [mutableChartData addObject:[NSString stringWithFormat:@"%.2f", totalDistance * 0.00062137119]];
                        }
                    }
                    else
                    {
                        totalDistance = 0;
                    }

                    [mutableChartData addObject:[NSString stringWithFormat:@"%f",totalDistance]];
                    oldLocation = runLoc;
                    break;
                }
                case 1:
                {
                    RunAltitude *ra = (RunAltitude *)[altitudePoints objectAtIndex:i];
                    [mutableChartData addObject:ra.altitude];
                    break;
                }
                case 2:
                {
                    RunLocations *runLoc = [runLocationsArray objectAtIndex:i];
                    [mutableChartData addObject:runLoc.locationTimeStamp];
                    break;
                }
                default:
                    break;
            }
        }
        [mutableLineCharts addObject:mutableChartData];
    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber;
    
    if (lineIndex == 0)
    {
        //Distance
        valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
        
        if([appDelegate useKMasUnits])
        {
            [self.informationView setValueText:[NSString stringWithFormat:@"%f", [valueNumber floatValue]] unitText:@"miles"];
        }
        else
        {
            [self.informationView setValueText:[NSString stringWithFormat:@"%f", [valueNumber floatValue]] unitText:@"miles"];
        }
        
        
        [self.informationView setTitleText:@"Distance"];
    }
    else if(lineIndex == 1)
    {
        valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
        [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"ft"];
        [self.informationView setTitleText:@"Climb"];
    }
    else if(lineIndex == 2)
    {
        valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
        [self.informationView setValueText:[NSString stringWithFormat:@"%@",[valueNumber stringValue]] unitText:@""];
        [self.informationView setTitleText:@"Time"];
    }
    [self.informationView setHidden:NO animated:YES];
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
