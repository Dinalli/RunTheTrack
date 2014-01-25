//
//  RunAltitudeViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "RunData.h"

@interface RunAltitudeViewController : UIViewController <CPTPlotDataSource>
{
    NSMutableArray *runAltArray;
    NSUInteger currentIndex;
    NSTimer *dataTimer;
}

-(void)newData:(NSTimer *)theTimer;

@property (nonatomic,strong) RunData *runData;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end
