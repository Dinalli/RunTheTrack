//
//  TrackInfoViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "TrackInfoViewController.h"
#import "StartViewController.h"

@interface TrackInfoViewController ()

@end

@implementation TrackInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setTrackInfo:(NSMutableDictionary *)trackInfoDict
{
    _trackInfo = trackInfoDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    trackDistance.text = [NSString stringWithFormat:@"%@ miles", [_trackInfo objectForKey:@"Distance"]];
    laps.text = [NSString stringWithFormat:@"%@ laps",[_trackInfo objectForKey:@"Laps"]];
    trackName.text = [_trackInfo objectForKey:@"Race"];
    trackMiniMap.image = [UIImage imageNamed:[_trackInfo objectForKey:@"mapimage"]];
    
    if(kenView.imagesArray == nil) kenView.imagesArray = [[NSMutableArray alloc] init];
    
    UIImage *trackImage = [UIImage imageNamed:[_trackInfo objectForKey:@"trackimage"]];
    [kenView.imagesArray addObject:trackImage];
    [kenView animateWithImages:kenView.imagesArray
            transitionDuration:2
                          loop:YES
                   isLandscape:YES];
    
    
    NSArray *points = [_trackInfo objectForKey:@"trackpoints"];
    
    if(points.count == 0) selectBtn.hidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"trackChosenSegue"]) {

        StartViewController *svc = segue.destinationViewController;
        svc.trackInfo = self.trackInfo;
    }
}


@end
