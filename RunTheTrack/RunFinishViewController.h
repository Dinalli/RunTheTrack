//
//  RunFinishViewController.h
//  RunTheTrack
//
//  Created by Andrew Donnelly on 27/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JBKenBurnsView.h"
#import "TTCounterLabel.h"

@class AppDelegate;

@interface RunFinishViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, TTCounterLabelDelegate,UIActionSheetDelegate>
{
    IBOutlet UIImageView *trackMapImage;
    UILabel *runTime;
    IBOutlet UILabel *runLaps;
    IBOutlet UILabel *runDistance;
    IBOutlet UILabel *runSteps;

    IBOutlet MKMapView *mv;
    
    UIImage *mapImage;
    
    IBOutlet UIView *toastView;
    
    double totalDistance;
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableDictionary *trackInfo;
@property (nonatomic) NSDictionary *runInfo;
@property (nonatomic, strong) NSMutableArray *trackPointArray;
@property (nonatomic, strong) MKPolyline* trackLine;
@property (nonatomic, strong) MKPolylineView* trackLineView;

@property (strong, nonatomic) IBOutlet TTCounterLabel *timeLabel;

@end
