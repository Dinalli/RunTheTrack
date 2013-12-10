//
//  TracksCollectionViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "TracksCollectionViewController.h"
#import "TrackCell.h"
#import "TrackInfoViewController.h"

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
    
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];

}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TrackInfoSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        TrackInfoViewController *tivc = segue.destinationViewController;
        
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        NSDictionary *selectedTrackInfo = [appDelegate.tracksArray  objectAtIndex:index.row];
        tivc.TrackInfo = [selectedTrackInfo mutableCopy];
        
        [self.collectionView
         deselectItemAtIndexPath:index animated:YES];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSDictionary *TrackInfo = [tracksArray objectAtIndex:indexPath.row];
//    
//    [self performSegueWithIdentifier:@"TrackInfoSegue"
//                              sender:TrackInfo];
//    [self.collectionView
//     deselectItemAtIndexPath:indexPath animated:YES];
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
                                  dequeueReusableCellWithReuseIdentifier:@"TrackCell"
                                  forIndexPath:indexPath];
    cell.trackName.text = [TrackInfo objectForKey:@"Race"];
    cell.imageView.image = [UIImage imageNamed:[TrackInfo objectForKey:@"mapimage"]];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark unwind Segue
- (IBAction)unwindToTracksCollection:(UIStoryboardSegue *)unwindSegue
{
}

@end
