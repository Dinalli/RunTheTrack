//
//  RunStatsViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/06/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunStatsViewController.h"
#import "AppDelegate.h"
#import "RunData.h"
#import "CoreDataHelper.h"
#import "RunAltitude.h"
#import "RunGraphViewController.h"

@interface RunStatsViewController ()
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
    CPTXYGraph *barChart;
    
    IBOutlet CPTGraphHostingView *graphView;
    
    NSMutableArray *altitudePoints;
}

@end

@implementation RunStatsViewController

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
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
        
        [self setupRunAltitude];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupRunAltitude
{
    // Set Up the data
    NSMutableArray *xAxisLabels = [NSMutableArray new];
    for (NSInteger index = 0; index < altitudePoints.count; index++) {
        RunAltitude *runAltitude = (RunAltitude *)[altitudePoints objectAtIndex:index];

        [xAxisLabels addObject:runAltitude.altitudeTimeStamp];
    }
    
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
    //CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    graphView.hostedGraph = barChart;
    
    // Border
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius    = 0.0f;
    barChart.plotAreaFrame.masksToBorder   = NO;
    
    // Paddings
    barChart.paddingLeft   = 0.0f;
    barChart.paddingRight  = 0.0f;
    barChart.paddingTop    = 0.0f;
    barChart.paddingBottom = 0.0f;
    
    barChart.plotAreaFrame.paddingLeft   = 70.0;
    barChart.plotAreaFrame.paddingTop    = 20.0;
    barChart.plotAreaFrame.paddingRight  = 20.0;
    barChart.plotAreaFrame.paddingBottom = 80.0;
    
    // Graph title
    NSString *lineOne = self.runData.runtrackname;
    NSString *lineTwo = @"Alititude";
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, lineOne.length)];
        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = CPTTextAlignmentCenter;
        [graphTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, graphTitle.length)];
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, lineOne.length)];
        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        barChart.attributedTitle = graphTitle;
    }
    else {
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color         = [CPTColor whiteColor];
        titleStyle.fontName      = @"Helvetica-Bold";
        titleStyle.fontSize      = 16.0;
        titleStyle.textAlignment = CPTTextAlignmentCenter;
        
        barChart.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
        barChart.titleTextStyle = titleStyle;
    }
    
    barChart.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(30.0f) length:CPTDecimalFromFloat(190.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromString(@"5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.title                       = @"Run";
    x.titleLocation               = CPTDecimalFromFloat(7.5f);
    x.titleOffset                 = 55.0f;
    
    // Define some custom labels for the data elements
    x.labelRotation  = M_PI / 4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:5], [NSDecimalNumber numberWithInt:10], [NSDecimalNumber numberWithInt:15], nil];
    //NSArray *xAxisLabels         = [NSArray arrayWithObjects:@"Label A", @"Label B", @"Label C", @"Label D", @"Label E", nil];
    NSUInteger labelLocation     = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = M_PI / 4;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = [NSSet setWithArray:customLabels];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromString(@"100");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.title                       = @"Distance";
    y.titleOffset                 = 2.0f;
    y.titleLocation               = CPTDecimalFromFloat(30.0f);
    
    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.baseValue  = CPTDecimalFromString(@"130");
    barPlot.dataSource = self;
    barPlot.barOffset  = CPTDecimalFromString(@"2.5f");
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
}


#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSLog(@"Count %d", altitudePoints.count);
    return altitudePoints.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
            case CPTBarPlotFieldBarTip:
            {
//                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:(index + 1) * (index + 1)];
//                if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
//                    num = [num decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
//                }
                
                RunAltitude *runAltitude = (RunAltitude *)[altitudePoints objectAtIndex:index];
                //NSLog(@"Alt %@", runAltitude.altitude);
                num = [NSDecimalNumber decimalNumberWithString:runAltitude.altitude];
                
                break;
            }
        }
    }
    
    return num;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RunGraphSegue"]) {
        RunGraphViewController *rsvc = segue.destinationViewController;
        [rsvc setRunData:self.runData];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end

