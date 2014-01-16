//
//  RunAltitudeViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryBaseViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface RunAltitudeViewController : HistoryBaseViewController <CPTPlotDataSource>
{
    NSMutableArray *runAltArray;
}

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end
