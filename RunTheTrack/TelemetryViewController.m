//
//  TelemetryViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 16/08/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "TelemetryViewController.h"
#import "JBLineChartView.h"
#import "JBChartHeaderView.h"
#import "JBLineChartFooterView.h"
#import "JBChartInformationView.h"
#import "RunLocations.h"

#define localize(key, default) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], default, nil)

#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

#pragma mark - Navigation

#define kJBColorNavigationBarTint UIColorFromHex(0xFFFFFF)
#define kJBColorNavigationTint UIColorFromHex(0x000000)

#pragma mark - Bar Chart

#define kJBColorBarChartControllerBackground UIColorFromHex(0x313131)
#define kJBColorBarChartBackground UIColorFromHex(0x3c3c3c)
#define kJBColorBarChartBarBlue UIColorFromHex(0x08bcef)
#define kJBColorBarChartBarGreen UIColorFromHex(0x34b234)
#define kJBColorBarChartHeaderSeparatorColor UIColorFromHex(0x686868)

#pragma mark - Line Chart

#define kJBColorLineChartControllerBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartBackground UIColorFromHex(0xb7e3e4)
#define kJBColorLineChartHeader UIColorFromHex(0x1c474e)
#define kJBColorLineChartHeaderSeparatorColor UIColorFromHex(0x8eb6b7)
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]
#define kJBColorLineChartDefaultSolidSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kJBColorLineChartDefaultDashedSelectedLineColor [UIColor colorWithWhite:1.0 alpha:1.0]

#pragma mark - Tooltips

#define kJBColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define kJBColorTooltipTextColor [UIColor redColor]



#define ARC4RANDOM_MAX 0x100000000

// Numerics
CGFloat const kJBLineChartViewControllerChartHeight = 350.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;
CGFloat const kJBLineChartViewControllerChartPaddingTop = 60.0f;
CGFloat const kJBLineChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBLineChartViewControllerChartHeaderPadding = 50.0f;
CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartSolidLineWidth = 6.0f;
CGFloat const kJBLineChartViewControllerChartDashedLineWidth = 2.0f;
NSInteger const kJBLineChartViewControllerMaxNumChartPoints = 7;
NSInteger const JBLineChartLineCount = 3;

// Strings
NSString * const kJBLineChartViewControllerNavButtonViewKey = @"view";

@interface TelemetryViewController ()  <JBLineChartViewDelegate, JBLineChartViewDataSource>
{
    AppDelegate *appDelegate;
}

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) JBChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *pointTimes;

// Helpers
- (void)initFakeData;
- (NSArray *)largestLineData; // largest collection of fake line data

@end

@implementation TelemetryViewController

#pragma mark - Alloc/Initx

- (id)init
{
    self = [super init];
    if (self)
    {
        //[self initRunData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //[self initRunData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //[self initFakeData];
    }
    return self;
}

#pragma mark - Data

- (void)initFakeData
{
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    for (int lineIndex=0; lineIndex<JBLineChartLineCount; lineIndex++)
    {
        NSMutableArray *mutableChartData = [NSMutableArray array];
        for (int i=0; i<kJBLineChartViewControllerMaxNumChartPoints; i++)
        {
            [mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX)]]; // random number between 0 and 1
        }
        [mutableLineCharts addObject:mutableChartData];
    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
    _pointTimes = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
}


-(void)initRunData
{
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    NSMutableArray *mutableLineTimes = [NSMutableArray array];
    
    NSArray *results = [[self.runData.runDataLocations allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"locationTimeStamp" ascending:YES]]];
    CLLocationDistance totalDistance  = 0;
//    for (int lineIndex=0; lineIndex<JBLineChartLineCount; lineIndex++)
//    {
        RunLocations *lastLocation = nil;
        NSMutableArray *mutabledistanceData = [NSMutableArray array];
        NSMutableArray *mutableSpeedData = [NSMutableArray array];
        NSMutableArray *mutableTotalDistanceData = [NSMutableArray array];

        for(RunLocations *rl in results)
        {
            if(lastLocation)
            {
                CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:[lastLocation.lattitude doubleValue] longitude:[lastLocation.longitude doubleValue]];
                CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[rl.lattitude doubleValue] longitude:[rl.longitude doubleValue]];
                CLLocationDistance distance = [endLocation distanceFromLocation:startLocation];
                
//                switch (lineIndex) {
//                    case 0:
//                    {

                        if([appDelegate useKMasUnits])
                        {
                            [mutabledistanceData addObject:[NSString stringWithFormat:@"%.2f", distance / 1000]];
                        }
                        else
                        {
                            [mutabledistanceData addObject:[NSString stringWithFormat:@"%.2f",distance * 0.000621371192]];
                        }
//                        break;
//                    }
//                    case 1:
//                    {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd/MMM/yyyy HH:mm:ss.SS"];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];

                        NSDate *date1 = [dateFormatter dateFromString:lastLocation.locationTimeStamp];
                        NSDate *date2 = [dateFormatter dateFromString:rl.locationTimeStamp];
                        
                        NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
                        CLLocationSpeed speed = distance / secondsBetween;
                        
                        //NSLog(@"%@ - %@ - Speed = %f",lastLocation.locationTimeStamp, rl.locationTimeStamp, speed);
                        
                        [mutableSpeedData addObject:[NSString stringWithFormat:@"%f",speed]]; // Speed
//                        break;
//                    }
//                    case 2:
//                    {
                        totalDistance = totalDistance + distance;
                        
                        if([appDelegate useKMasUnits])
                        {
                            [mutableTotalDistanceData addObject:[NSString stringWithFormat:@"%.2f", totalDistance / 1000]];
                        }
                        else
                        {
                            [mutableTotalDistanceData addObject:[NSString stringWithFormat:@"%.2f",totalDistance * 0.000621371192]];
                        }
//                        break;
//                    }
//                    default:
//                        break;
//                }
            }
            else
            {
                [mutabledistanceData addObject:[NSString stringWithFormat:@"%d",0]];
                [mutableSpeedData addObject:[NSString stringWithFormat:@"%d",0]];
                [mutableTotalDistanceData addObject:[NSString stringWithFormat:@"%d",0]];// Distance, total or speed
            }
            
            lastLocation = rl;
        }
        [mutableLineCharts addObject:mutabledistanceData];
        [mutableLineCharts addObject:mutableSpeedData];
        [mutableLineCharts addObject:mutableTotalDistanceData];
//    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
    
    for (int lineIndex=0; lineIndex<JBLineChartLineCount; lineIndex++)
    {
        for(RunLocations *rl in results)
        {
            [mutableLineTimes addObject:rl.locationTimeStamp];
        }
    }
    _pointTimes = [NSArray arrayWithArray:mutableLineTimes];
}

- (NSArray *)largestLineData
{
    NSArray *largestLineData = nil;
    for (NSArray *lineData in self.chartData)
    {
        if ([lineData count] > [largestLineData count])
        {
            largestLineData = lineData;
        }
    }
    return largestLineData;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initRunData];
    
    self.view.backgroundColor = kJBColorLineChartControllerBackground;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kJBLineChartViewControllerChartPadding, kJBLineChartViewControllerChartPaddingTop, self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding = kJBLineChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = [UIColor clearColor];
    
    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = [self.runData.runtrackname uppercaseString];
    headerView.titleLabel.textColor = kJBColorLineChartHeader;
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.subtitleLabel.text = [self.runData rundate];
    headerView.subtitleLabel.textColor = kJBColorLineChartHeader;
    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.separatorColor = kJBColorLineChartHeaderSeparatorColor;
    self.lineChartView.headerView = headerView;
    
    JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.leftLabel.text = [[self.pointTimes firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.pointTimes lastObject] uppercaseString];;
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = [[self largestLineData] count];
    self.lineChartView.footerView = footerView;
    
    [self.view addSubview:self.lineChartView];
    
    self.informationView = [[JBChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    //[self.informationView setTitleTextColor:kJBColorLineChartHeader];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kJBColorLineChartHeaderSeparatorColor];
    [self.view addSubview:self.informationView];
    
    [self.lineChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.lineChartView setState:JBChartViewStateExpanded];
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    //NSLog(@"Line index %d Horizontal Index %d Data %@ ", lineIndex, horizontalIndex, [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex]);
    return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    //NSLog(@"Line index %d Horizontal Index %d ", lineIndex, horizontalIndex);
    NSNumber *valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
    
    switch (lineIndex) {
        case 0:
        {
            if([appDelegate useKMasUnits])
            {
                [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"km"];
            }
            else
            {
                [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"miles"];
            }
            
            [self.informationView setTitleText:@"Distance"];
            break;
        }
        case 1:
        {
            [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"mph"];
            [self.informationView setTitleText:@"Speed"];
            break;
        }
        case 2:
        {
            if([appDelegate useKMasUnits])
            {
                [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"km"];
            }
            else
            {
                [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:@"miles"];
            }
            [self.informationView setTitleText:@"Total Distance "];
            break;
        }
    }

    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MMM/yyyy HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSDate *date1 = [dateFormatter dateFromString:[self.pointTimes objectAtIndex:horizontalIndex]];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [self.tooltipView setText:[[dateFormatter stringFromDate:date1] uppercaseString]];
}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.chartData count];
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:lineIndex] count];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    switch (lineIndex) {
        case 0:
            return [UIColor greenColor];
            break;
        case 1:
            return [UIColor orangeColor];
            break;
        case 2:
            return [UIColor redColor];
            break;
        default:
            break;
    }
    
    return [UIColor blueColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    switch (lineIndex) {
        case 0:
            return [UIColor yellowColor];
            break;
        case 1:
            return [UIColor yellowColor];
            break;
        case 2:
            return [UIColor yellowColor];
            break;
        default:
            break;
    }
    
    return [UIColor yellowColor];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBLineChartViewControllerChartSolidLineWidth;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 0.5;
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [UIColor blueColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor blueColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor greenColor];
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 0;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.lineChartView;
}

@end
