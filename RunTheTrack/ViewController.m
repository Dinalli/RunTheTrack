//
//  ViewController.m
//  RunTheTrack
//
//  Created by Andrew Donnelly on 19/09/2013.
//  Copyright (c) 2013 iphonemobileapp. All rights reserved.
//

#import "ViewController.h"
#import "RTTTrackScroller.h"
#import "RTTTrackInfoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    RTTTrackScroller *scrollerView = [[RTTTrackScroller alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scrollerView];
    
    //Load the plist
    //Loop it and build trackInfos for tracks
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* plistPath = [bundle pathForResource:@"Tracks" ofType:@"plist"];
    NSMutableDictionary *tracksDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *trackKeys = [tracksDict allKeys];
    int firstX = 0;
    
    for (NSString *key in trackKeys) {
        NSDictionary *TrackInfo = [tracksDict objectForKey:key];
        
        RTTTrackInfoView *trackInfo = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(firstX, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [trackInfo setBackImage:[UIImage imageNamed:@"Silverstoneback.png"]];
        [trackInfo setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
        [trackInfo setTrackDistance:[TrackInfo objectForKey:@"Distance"]];
        [trackInfo setTrackLaps:[TrackInfo objectForKey:@"Laps"]];
        [trackInfo setTrackName:key];
        [scrollerView addSubview:trackInfo];
        
        firstX += 320;
    }
    
//    RTTTrackInfoView *trackInfo = [[RTTTrackInfoView alloc] initWithFrame:self.view.frame];
//    [trackInfo setBackImage:[UIImage imageNamed:@"Silverstoneback.png"]];
//    [trackInfo setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo setTrackDistance:@"3.25"];
//    [trackInfo setTrackLaps:@"56"];
//    [trackInfo setTrackName:@"Silverstone"];
//    [scrollerView addSubview:trackInfo];
//    
//    RTTTrackInfoView *trackInfo1 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo1 setBackImage:[UIImage imageNamed:@"SPA.png"]];
//    [trackInfo1 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo1 setTrackName:@"Spa"];
//    [scrollerView addSubview:trackInfo1];
//    
//    RTTTrackInfoView *trackInfo2 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320*2, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo2 setBackImage:[UIImage imageNamed:@"Monza.png"]];
//    [trackInfo2 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo2 setTrackName:@"Monza"];
//    [scrollerView addSubview:trackInfo2];
//    
//    RTTTrackInfoView *trackInfo3 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320*3, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo3 setBackImage:[UIImage imageNamed:@"Singapore.png"]];
//    [trackInfo3 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo3 setTrackName:@"Singapore"];
//    [scrollerView addSubview:trackInfo3];
//    
//    RTTTrackInfoView *trackInfo4 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320*4, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo4 setBackImage:[UIImage imageNamed:@"Silverstoneback.png"]];
//    [trackInfo4 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo4 setTrackName:@"Brazil"];
//    [scrollerView addSubview:trackInfo4];
//    
//    RTTTrackInfoView *trackInfo5 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320*5, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo5 setBackImage:[UIImage imageNamed:@"Oz.png"]];
//    [trackInfo5 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo5 setTrackName:@"Austrailia"];
//    [scrollerView addSubview:trackInfo5];
//    
//    RTTTrackInfoView *trackInfo6 = [[RTTTrackInfoView alloc] initWithFrame:CGRectMake(320*6, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [trackInfo6 setBackImage:[UIImage imageNamed:@"Monaco.png"]];
//    [trackInfo6 setTrackMap:[UIImage imageNamed:@"silverstone_off.png"]];
//    [trackInfo6 setTrackName:@"Monaco"];
//    [scrollerView addSubview:trackInfo6];
    
    [scrollerView setPagingEnabled:YES];
    [scrollerView setContentSize:CGSizeMake(320*trackKeys.count, self.view.frame.size.height)];
    
    UIButton *burgerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [burgerButton setImage:[UIImage imageNamed:@"burger.png"] forState:UIControlStateNormal];
    [burgerButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [burgerButton setFrame:CGRectMake(5, 25, 34, 34)];
    [self.view addSubview:burgerButton];
}

- (void)showMenu
{
    if (!_sideMenu) {
        RESideMenuItem *tracksMenuItem = [[RESideMenuItem alloc] initWithTitle:@"Tracks" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
        }];
        RESideMenuItem *progressMenuItem = [[RESideMenuItem alloc] initWithTitle:@"Progress" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
        }];
        
        RESideMenuItem *musicMenuItem = [[RESideMenuItem alloc] initWithTitle:@"Music" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
        }];
        
        RESideMenuItem *achivementsMenuItem = [[RESideMenuItem alloc] initWithTitle:@"Achivements" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
        }];
        RESideMenuItem *settingsItem = [[RESideMenuItem alloc] initWithTitle:@"Settings" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
        }];
        
        RESideMenuItem *homeItem = [[RESideMenuItem alloc] initWithTitle:@"Home" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[tracksMenuItem, progressMenuItem, musicMenuItem, achivementsMenuItem, settingsItem, homeItem]];
        _sideMenu.backgroundImage = [UIImage imageNamed:@"silverstoneback.png"];
    }
    
    [_sideMenu show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
