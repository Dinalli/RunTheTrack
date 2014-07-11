//
//  TracksCollectionViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCell.h"
#import "RunViewController.h"
#import "MTZWhatsNew.h"
#import "MTZWhatsNewGridViewController.h"
#import "LoginViewController.h"

@interface TracksCollectionViewController ()

@end

@implementation TracksCollectionViewController

    
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
//        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
//        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
//            adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
//        } else {
//            adView = [[ADBannerView alloc] init];
//        }
//        adView.delegate = self;
    }
    return self;
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.canDisplayBannerAds = YES;
    
    adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    adView.delegate = self;
    [self.view addSubview:adView];
    
#ifdef DEBUG
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	
	// For the sake of debugging, manually set the last version of the app used to 0.
	// Do not include this in shipping code.
	[MTZWhatsNew performSelector:@selector(setLastAppVersion:) withObject:@"0.0"];
	
#pragma clang diagnostic pop
#endif
    
    [MTZWhatsNew handleWhatsNew:^(NSDictionary *whatsNew) {
		// Creating the view controller with features.
		MTZWhatsNewGridViewController *vc = [[MTZWhatsNewGridViewController alloc] initWithFeatures:whatsNew];
		// Customizing the background gradient.
		vc.backgroundGradientTopColor = [UIColor colorWithHue:0.77 saturation:0.77 brightness:0.76 alpha:1];
		vc.backgroundGradientBottomColor = [UIColor colorWithHue:0.78 saturation:0.6 brightness:0.95 alpha:1];
		// Presenting the what's new view controller.
		[self presentViewController:vc animated:NO completion:^{
        }];
	}];
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        // show the signup or login screen
        [[MessageBarManager sharedInstance] showMessageWithTitle:@"No Current User" description:@"Please Login if you wish to use Sharing features of the App." type:MessageBarMessageTypeInfo];
        // Show login message
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TrackSelectedSegue"]) {
        NSArray *indexPaths = [collectionView indexPathsForSelectedItems];
        RunViewController *rvc = segue.destinationViewController;
        
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        NSDictionary *selectedTrackInfo = [appDelegate.tracksArray  objectAtIndex:index.row];
        rvc.TrackInfo = [selectedTrackInfo mutableCopy];
        
        [collectionView
         deselectItemAtIndexPath:index animated:YES];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view
     numberOfItemsInSection:(NSInteger)section {
    return [appDelegate.tracksArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *TrackInfo = (NSMutableDictionary *)[appDelegate.tracksArray objectAtIndex:indexPath.row];

    TrackCell *cell = [cv
                                  dequeueReusableCellWithReuseIdentifier:@"TrackDetailCell"
                                  forIndexPath:indexPath];
    
    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
    cell.totalLaps.text = [NSString stringWithFormat:@"Laps : %@",[TrackInfo objectForKey:@"Laps"]];
    cell.Distance.text = [NSString stringWithFormat:@"Distance : %@ miles",[TrackInfo objectForKey:@"Distance"]];
    
    cell.trackImage.image = [UIImage imageNamed:[TrackInfo objectForKey:@"mapimage"]];
    return cell;
}

- (IBAction)unwindToTrackSelect:(UIStoryboardSegue *)unwindSegue
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)viewDidLayoutSubviews {
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [adView sizeThatFits:contentFrame.size];
    
    if (adView.bannerLoaded) {
        contentFrame.size.height -= bannerFrame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    adView.frame = bannerFrame;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
    {
        NSLog(@"Banner View Did load Ad");
    }
    
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
    {
        NSLog(@"Banner Error %@", error.localizedDescription);
    }

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
    {
        NSLog(@"Banner View Should begin YES");
        return YES;
    }
    
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
    {
        NSLog(@"Banner Action Did Finish");
    }

@end
