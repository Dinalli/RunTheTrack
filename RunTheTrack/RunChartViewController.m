//
//  RunChartViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 28/07/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunChartViewController.h"
#import "DPlotChart.h"
#import "CoreDataHelper.h"
#import "RunLocations.h"
#import "RunAltitude.h"
#import "AppDelegate.h"

@implementation RunChartViewController
{
    NSMutableArray *runs;
    AppDelegate *appDelegate;
    NSArray *chartData;
    NSMutableArray *altitudePoints;
}

-(void)viewDidLoad
{
    [self loadGraphData];
    NSOrderedSet *runChartSet = [NSOrderedSet orderedSetWithArray:[chartData valueForKeyPath:@"@distinctUnionOfObjects.TimeStamp"]];
    DPlotChart *plotChart = [[DPlotChart alloc] initWithFrame:CGRectMake(10, 70, 250, 300)];
    [plotChart createChartWith:runChartSet];
    [self.view addSubview:plotChart];
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
    //    for (int lineIndex=0; lineIndex<1; lineIndex++)
    //    {
    NSMutableDictionary *mutableChartData = [NSMutableDictionary dictionary];
    for (int i=0; i<runLocationsArray.count; i++)
    {
        CLLocation *lastLocation;
        //            switch (lineIndex) {
        //                case 0:
        //                {
        RunLocations *runLoc = [runLocationsArray objectAtIndex:i];
        if(oldLocation)
        {
            lastLocation = [[CLLocation alloc] initWithLatitude:[oldLocation.lattitude doubleValue] longitude:[oldLocation.longitude doubleValue]];
            
            CLLocation *nextLocation = [[CLLocation alloc] initWithLatitude:[runLoc.lattitude doubleValue] longitude:[runLoc.longitude doubleValue]];
            CLLocationDistance distance = [nextLocation distanceFromLocation:lastLocation];
            totalDistance = totalDistance + distance;
            
            if([appDelegate useKMasUnits])
            {
                [mutableChartData setValue:[NSString stringWithFormat:@"%.2f", totalDistance / 1000] forKey:@"Distance"];
            }
            else
            {
                [mutableChartData setValue:[NSString stringWithFormat:@"%.2f", totalDistance * 0.00062137119] forKey:@"Distance"];
            }
        }
        else
        {
            totalDistance = 0;
        }
        
        [mutableChartData setValue:[NSString stringWithFormat:@"%f",totalDistance] forKey:@"TotalDistance"];
        
        [mutableChartData setValue:runLoc.locationTimeStamp forKey:@"TimeStamp"];
        oldLocation = runLoc;
        //break;
        //                }
        //                case 1:
        //                {
        //                    RunAltitude *ra = (RunAltitude *)[altitudePoints objectAtIndex:i];
        //                    [mutableChartData addObject:ra.altitude];
        //                    break;
        //                }
        //                case 2:
        //                {
        //                    RunLocations *runLoc = [runLocationsArray objectAtIndex:i];
        //                    [mutableChartData addObject:runLoc.locationTimeStamp];
        //                    break;
        //                }
        //                default:
        //                    break;
        //            }
        //        }
        [mutableLineCharts addObject:mutableChartData];
    }
    chartData = [NSArray arrayWithArray:mutableLineCharts];
}


@end
