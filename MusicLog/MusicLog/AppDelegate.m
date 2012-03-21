//
//  AppDelegate.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ScalePickerVC.h"
#import "SessionStore.h"
#import "PiecesPickerVC.h"
#import "StatsVC.h"
#import "Session.h"
#import "Piece.h"
#import "Timer.h"
#import "BlockAlertView.h"
#import "SectionInfo.h"
#import "HistoryViewController.h"
#import "ContainerViewController.h"

@interface AppDelegate()
@property (nonatomic, strong) StatsVC *c;
@property (nonatomic, strong) HistoryViewController *historyViewController;
@property (nonatomic, strong) ContainerViewController *containerViewController;
@property (nonatomic) BOOL alertViewVisible;
- (void)checkDate;
@end
@implementation AppDelegate

@synthesize window = _window, c, alertViewVisible;
@synthesize historyViewController, containerViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
    /*remove later*/[TestFlight takeOff:@"0bb5b0fae5868594a374b52c1cd204c3_NTQ5NTIyMDEyLTAxLTI1IDE1OjU3OjIxLjYxMTI3NA"];
     application.applicationSupportsShakeToEdit = YES; /**/
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [self setAlertViewVisible:NO];
    [SessionStore defaultStore];
    [self checkDate];
    
    c = [[StatsVC alloc] init];
    historyViewController = [[HistoryViewController alloc] initWithNibName:nil bundle:nil];
    containerViewController = [[ContainerViewController alloc] initWithNibName:nil bundle:nil];
    [[historyViewController view] setFrame:[_window frame]];
    [[c view] setFrame:[[historyViewController view] frame]];
    [containerViewController addChildViewController:c];
    [containerViewController addChildViewController:historyViewController];
    [[historyViewController view] addSubview:[c view]];
    [[containerViewController view] addSubview:[historyViewController view]];
    [self.window setRootViewController:containerViewController];
    [self checkDate];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)timerFireMethod:(NSTimer *)timer
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkDate];
}

- (void)checkDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[[SessionStore defaultStore] mySession] date]];
    NSDate *sessionDate = [cal dateFromComponents:components];
    
    if (![sessionDate isEqualToDate:today] && !alertViewVisible)
    {
        
        BlockAlertView *freshDay = [BlockAlertView alertWithTitle:@"A New Day, A New Practice"
                                                        message:@"Would you like your new practice to start out with all of the same items (scales, pieces, etc.) as your last practice?"];
        [freshDay addButtonWithTitle:@"Yes Please!" block:^{
            [c blockAlertView:NO];
            [self setAlertViewVisible:NO];
        }];
        [freshDay setCancelButtonWithTitle:@"No Thanks" block:^{
            [c blockAlertView:YES];
            [self setAlertViewVisible:NO];
        }];
        [freshDay show];
        [self setAlertViewVisible:YES];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[SessionStore defaultStore] saveChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SessionStore defaultStore] saveChanges];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[SessionStore defaultStore] saveChanges];
}

@end
