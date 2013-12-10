//
//  AchivementsCollectionViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 14/10/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "AchivementsCollectionViewController.h"
#import "AchivementCell.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "RunAchievement.h"

@implementation AchivementsCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    
    runAchivements = [CoreDataHelper getObjectsFromContextWithEntityName:@"RunAchievement" andSortKey:nil andSortAscending:YES withManagedObjectContext:self.managedObjectContext];
    
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view
     numberOfItemsInSection:(NSInteger)section {
    return runAchivements.count;
}

- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AchivementCell *cell = [cv
                       dequeueReusableCellWithReuseIdentifier:@"AchivementCell"
                       forIndexPath:indexPath];
    RunAchievement *ra = (RunAchievement *)[runAchivements objectAtIndex:indexPath.row];
    
    cell.label.text =  ra.achievementText;
    cell.imageView.image = [UIImage imageNamed:@"routes-cup.png"];
    return cell;
}

@end
