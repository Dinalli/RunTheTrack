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

@interface RunGraphViewController ()
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
    NSMutableArray *altitudePoints;
    NSMutableArray *points;
}

@property (nonatomic, strong) JBChartInformationView *informationView;

@end

@implementation RunGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadGraph];
    
    JBLineChartView *lineChartView = [[JBLineChartView alloc] init];
    lineChartView.frame = CGRectMake(0,50,320,280);
    lineChartView.backgroundColor = [UIColor lightGrayColor];
    lineChartView.delegate = self;
    lineChartView.dataSource = self;
    [self.view addSubview:lineChartView];
    
    self.informationView = [[JBChartInformationView alloc]
                            initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(lineChartView.frame),
                                                     self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.informationView setTitleTextColor:[UIColor greenColor]];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:[UIColor blueColor]];
    [self.view addSubview:self.informationView];
    
    [lineChartView reloadData];
}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return points.count;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    //NSLog(@"Vertical Value %@", [points objectAtIndex:lineIndex]);
    return [[points objectAtIndex:lineIndex] floatValue];// y-position (y-axis) of point at horizontalIndex (x-axis)
}


-(void)loadGraph
{
    
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
    }
    NSMutableArray *xAxisLabels = [NSMutableArray new];
    NSMutableArray *components = [NSMutableArray array];
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
    [self.informationView setTitleText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]]];
    //[self.informationView setTitleText:lineIndex == JBLineChartLineSolid ? kJBStringLabelMetropolitanAverage : kJBStringLabelNationalAverage];
    [self.informationView setHidden:NO animated:YES];
    //[self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    //[self.tooltipView setText:[[self.daysOfWeek objectAtIndex:horizontalIndex] uppercaseString]];
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
