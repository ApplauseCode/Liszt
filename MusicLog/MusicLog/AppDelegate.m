//
//  AppDelegate.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ScalesArpeggiosVC.h"
#import "ScalePickerVC.h"
#import "ScaleStore.h"
#import "BlankVC.h"
#import "PiecesPickerVC.h"
#import "StatsVC.h"
#import "Session.h"

@interface AppDelegate()
{
    ScalesArpeggiosVC *spt, *apt, *ppt;

}
@end
@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize tabBarIndex;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    StatsVC *c = [[StatsVC alloc] init];
    UINavigationController *homePage = [[UINavigationController alloc] initWithRootViewController:c];
    
    UINavigationBar *homeBar = homePage.navigationBar;
    UIImage *navImage = [UIImage imageNamed:@"LisztNavBar"];
    [homeBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    
    [self.window setRootViewController:homePage];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [spt sessionSave];
    [apt sessionSave];
    [ppt sessionSave];
    [[ScaleStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [spt sessionSave];
    [apt sessionSave];
    [ppt sessionSave];
    [[ScaleStore defaultStore] saveChanges];
}

- (void)middleTab {}

@end
