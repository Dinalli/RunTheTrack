//
//  RunMapViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/01/2014.
//  Copyright (c) 2014 iphonemobileapp. All rights reserved.
//

#import "RunOverviewViewController.h"
#import "UIImage+ImageEffects.h"

@implementation RunOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    timeView.layer.masksToBounds = NO;
    timeView.layer.shadowOffset = CGSizeMake(0,-3);
    timeView.layer.shadowRadius = 2;
    timeView.layer.shadowOpacity = 0.7;
    timeView.layer.cornerRadius = 4;
    timeView.layer.borderColor = [[UIColor blackColor] CGColor];
    timeView.layer.borderWidth = 0.5;
    
    trackInfoView.layer.masksToBounds = NO;
    trackInfoView.layer.shadowOffset = CGSizeMake(0,-3);
    trackInfoView.layer.shadowRadius = 2;
    trackInfoView.layer.shadowOpacity = 0.7;
    trackInfoView.layer.cornerRadius = 4;
    trackInfoView.layer.borderColor = [[UIColor blackColor] CGColor];
    trackInfoView.layer.borderWidth = 0.5;
    
    runDetailsView.layer.masksToBounds = NO;
    runDetailsView.layer.shadowOffset = CGSizeMake(0,-3);
    runDetailsView.layer.shadowRadius = 2;
    runDetailsView.layer.shadowOpacity = 0.7;
    runDetailsView.layer.cornerRadius = 4;
    runDetailsView.layer.borderColor = [[UIColor blackColor] CGColor];
    runDetailsView.layer.borderWidth = 0.5;
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [timeView addMotionEffect:group];
    [trackInfoView addMotionEffect:group];
    [runDetailsView addMotionEffect:group];
    [self initFlatWithIndicatorProgressBar];
    [self.progressBarFlatWithIndicator setProgress:0.4 animated:YES];
    
    [self setUpRunData];
}

-(void)setUpRunData
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate useKMasUnits])
    {
        runDistance.text = [NSString stringWithFormat:@"%.02f km", [self.runData.rundistance floatValue] / 1000];
    }
    else
    {
        runDistance.text = [NSString stringWithFormat:@"Distance %.2f miles",[self.runData.rundistance floatValue] * 0.000621371192];
    }
    
    runDate.text = [NSString stringWithFormat:@"Date : %@",self.runData.rundate];
    self.navigationItem.title = self.runData.runtrackname;
    
    for (NSMutableDictionary *trackInfoDict in appDelegate.tracksArray) {
        if([[trackInfoDict objectForKey:@"Race"] isEqualToString:self.runData.runtrackname])
        {
            self.trackInfo = trackInfoDict;
            backgroundImageView.image = [[UIImage imageNamed:[trackInfoDict objectForKey:@"trackimage"]] applyExtraLightEffect];
        }
    }

}

- (void)initFlatWithIndicatorProgressBar
{
    _progressBarFlatWithIndicator.type                     = YLProgressBarTypeFlat;
    _progressBarFlatWithIndicator.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _progressBarFlatWithIndicator.behavior                 = YLProgressBarBehaviorIndeterminate;
    _progressBarFlatWithIndicator.stripesOrientation       = YLProgressBarStripesOrientationVertical;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [_progressBarFlatWithIndicator setProgress:progress animated:animated];
}

@end
