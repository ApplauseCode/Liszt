//
//  AppDelegate.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/29/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import "AppDelegate.h"
#import "ScalePickerVC.h"
#import "SessionStore.h"
#import "PiecesPickerVC.h"
#import "StatsVC.h"
#import "Session.h"
#import "Piece.h"
#import "BlockAlertView.h"
#import "SectionInfo.h"
#import "HistoryViewController.h"
#import "ContainerViewController.h"

@interface AppDelegate()
@property (nonatomic, strong) StatsVC *statsVC;
@property (nonatomic, strong) HistoryViewController *historyViewController;
@property (nonatomic, strong) ContainerViewController *containerViewController;
@property (nonatomic) BOOL alertViewVisible;
- (void)checkDate;
@end
@implementation AppDelegate

@synthesize window = _window, statsVC, alertViewVisible;
@synthesize historyViewController, containerViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    /*remove later*/
//    [TestFlight takeOff:@"0bb5b0fae5868594a374b52c1cd204c3_NTQ5NTIyMDEyLTAxLTI1IDE1OjU3OjIxLjYxMTI3NA"];
//     application.applicationSupportsShakeToEdit = YES; /**/
    [self setAlertViewVisible:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isFirstLaunch = [NSNumber numberWithBool:YES];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:isFirstLaunch, @"FirstLaunch", nil];
    [defaults registerDefaults:appDefaults];
    if ([[defaults objectForKey:@"FirstLaunch"] boolValue]) {
        Session *firstSession = [[Session alloc] init];
        [[SessionStore defaultStore] setMySession:firstSession];
    }
    else {
        [self checkDate];
        
    }

    statsVC = [[StatsVC alloc] init];
    historyViewController = [[HistoryViewController alloc] initWithNibName:nil bundle:nil];
    containerViewController = [[ContainerViewController alloc] initWithNibName:nil bundle:nil];
    [[historyViewController view] setFrame:[self.window frame]];
    [[statsVC view] setFrame:[[historyViewController view] frame]];
    [containerViewController addChildViewController:statsVC];
    [containerViewController addChildViewController:historyViewController];
    // StatsVC at index 0, historyVC at index 1
    [containerViewController setViewControllers:[NSMutableArray arrayWithObjects:statsVC, historyViewController, nil]];
    
    [[historyViewController view] addSubview:[statsVC view]];
    [[containerViewController view] addSubview:[historyViewController view]];
    [self.window setRootViewController:containerViewController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self checkDate];
    [statsVC setScreenBrightness:[statsVC screenBrightness]];
    [statsVC startTimers];

}

- (void)checkDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[[SessionStore defaultStore] mySession] date]];
    NSDate *sessionDate = [cal dateFromComponents:components];
        
    NSDate *fromDate;
    NSDate *toDate;
    [cal rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:sessionDate];
    [cal rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:today];
    
    NSDateComponents *difference = [cal components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    if ([difference day] > 0 && !alertViewVisible)
    {
        SessionStore *store = [SessionStore defaultStore];
        [[store sessions] addObject:[store mySession]];
        
        for (int i = [difference day] - 1; i > 0; i--)
        {
            NSDateComponents *days = [[NSDateComponents alloc] init];
            [days setDay:-i];
            Session *blankSession = [[Session alloc] initWithScales:nil arpeggios:nil pieces:nil];
            [blankSession setDate:[cal dateByAddingComponents:days toDate:[NSDate date] options:0]];
            [[store sessions] addObject:blankSession];
        }
        [[SessionStore defaultStore] updateDict];
        BlockAlertView *freshDay = [BlockAlertView alertWithTitle:@"A New Day,\nA New Practice"
                                                          message:@"Would you like to start your new practice with all of the same items (scales, pieces, etc.) as your last practice?"];
        [freshDay addButtonWithTitle:@"Yes Please!" block:^{
            [statsVC blockAlertView:NO];
            [self setAlertViewVisible:NO];
            [historyViewController loadData];
        }];
        [freshDay setCancelButtonWithTitle:@"No Thanks" block:^{
            [statsVC blockAlertView:YES];
            [self setAlertViewVisible:NO];
            [historyViewController loadData];
        }];
        [freshDay show];
        [self setAlertViewVisible:YES];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [statsVC stopAllTimers];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        [[SessionStore defaultStore] saveChanges];
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_async(queue, ^{
        [[SessionStore defaultStore] saveChanges];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    dispatch_async(queue, ^{
        [[SessionStore defaultStore] saveChanges];
    });
}

@end
