//
//  AppDelegate.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ScalePickerVC.h"
#import "ScaleStore.h"
#import "BlankVC.h"
#import "PiecesPickerVC.h"
#import "StatsVC.h"
#import "Session.h"
#import "Piece.h"
#import "Timer.h"

@interface AppDelegate()
{
    StatsVC *c;
}
@end
@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    c = [[StatsVC alloc] init];
    //UINavigationController *homePage = [[UINavigationController alloc] initWithRootViewController:c];
    
    //UINavigationBar *homeBar = homePage.navigationBar;
    UIImage *navImage = [UIImage imageNamed:@"LisztNavBar"];
    //[homeBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    
    [self.window setRootViewController:c];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ScaleStore *store = [ScaleStore defaultStore];
    [[c scaleTimer] stopTimer];
    [[c arpeggioTimer] stopTimer];
    [[store mySession] setScaleTime:[[c scaleTimer] elapsedTime]];
    [[store mySession] setArpeggioTime:[[c arpeggioTimer] elapsedTime]];
    for (Piece *p in [[store mySession] pieceSession])
    {
        [[p timer] stopTimer];
        [p setPieceTime:[[p timer] elapsedTime]];
    }
    [[ScaleStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    ScaleStore *store = [ScaleStore defaultStore];
    [[c scaleTimer] stopTimer];
    [[c arpeggioTimer] stopTimer];
    [[store mySession] setScaleTime:[[c scaleTimer] elapsedTime]];
    [[store mySession] setArpeggioTime:[[c arpeggioTimer] elapsedTime]];
    for (Piece *p in [[store mySession] pieceSession])
    {
        [[p timer] stopTimer];
        [p setPieceTime:[[p timer] elapsedTime]];
    }
    [[ScaleStore defaultStore] saveChanges];
}

@end
