//
//  TracksCollectionViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCell.h"
#import "StartViewController.h"

@interface TracksCollectionViewController ()

@end

@implementation TracksCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TrackSelectedSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        StartViewController *svc = segue.destinationViewController;
        
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        NSDictionary *selectedTrackInfo = [appDelegate.tracksArray  objectAtIndex:index.row];
        svc.TrackInfo = [selectedTrackInfo mutableCopy];
        
        TFLog(@"Track Chosen %@", [selectedTrackInfo objectForKey:@"Race"]);
        
        [self.collectionView
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
    
    cell.kenView.imagesArray = [[NSMutableArray alloc] init];
    UIImage *trackImage = [UIImage imageNamed:[TrackInfo objectForKey:@"trackimage"]];
    [cell.kenView.imagesArray addObject:trackImage];
    [cell.kenView animateWithImages:cell.kenView.imagesArray
            transitionDuration:20
                          loop:YES
                   isLandscape:YES];
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
@end
