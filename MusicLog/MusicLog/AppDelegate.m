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
#import "BlankVC.h"
#import "PiecesPickerVC.h"
#import "StatsVC.h"
#import "Session.h"
#import "Piece.h"
#import "Timer.h"
#import "BlockAlertView.h"
#import "SectionInfo.h"

@interface AppDelegate()
{
    StatsVC *c;
}
- (void)checkDate;
@end
@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    /*remove later*/[TestFlight takeOff:@"0bb5b0fae5868594a374b52c1cd204c3_NTQ5NTIyMDEyLTAxLTI1IDE1OjU3OjIxLjYxMTI3NA"];
     application.applicationSupportsShakeToEdit = YES; /**/
    [self checkDate];
    
    c = [[StatsVC alloc] init];
    [self.window setRootViewController:c];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)checkDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:-86400/*seconds in a day*/]];
    NSDate *yesterday = [cal dateFromComponents:components];
    NSLog(@"yesterday: %@", yesterday);
    
    components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[[SessionStore defaultStore] mySession] date]];
    NSDate *sessionDate = [cal dateFromComponents:components];
    
    if ([sessionDate isEqualToDate:yesterday])
    {
        BlockAlertView *newDay = [BlockAlertView alertWithTitle:@"A New Day, A New Practice"
                                                        message:@"Would you like your new practice to start out with all of the same items (scales, pieces, etc.) as your last practice?"];
        [newDay addButtonWithTitle:@"Yes Please!" block:^{
            [c blockAlertView:NO];
        }];
        [newDay setCancelButtonWithTitle:@"No Thanks" block:^{
            [c blockAlertView:YES];
        }];
        [newDay show];
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

@end
