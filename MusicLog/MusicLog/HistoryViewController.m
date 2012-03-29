//
//  HistoryViewController.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCell.h"
#import "SessionStore.h"
#import "Session.h"
#import "Piece.h"
#import "NSString+Number.h"
#import "ContainerViewController.h"
#import "StatsVC.h"

@interface HistoryViewController ()

@property (nonatomic, strong) NSMutableArray *sessionDates;
@property (nonatomic, strong) NSMutableArray *sessionTimes;
@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) IBOutlet UITableView *historyTableView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (strong, nonatomic) UIButton *chooseDateButton;
@property (nonatomic, assign) CGPoint containerCenter;
- (void)scrollToDate:(NSDate *)date;
- (void)presentDatePicker:(UIButton *)button;

@end

@implementation HistoryViewController
@synthesize sessionTimes;
@synthesize sessionDates;
@synthesize sessions;
@synthesize historyTableView;
@synthesize datePicker;
@synthesize chooseDateButton;
@synthesize containerCenter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, -216, 320, 253)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMaximumDate:[NSDate date]];
    [self.view addSubview:datePicker];
    chooseDateButton = [[UIButton alloc] init];
    [chooseDateButton addTarget:self action:@selector(presentDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    sessionDates = [[NSMutableArray alloc] init];
    sessionTimes = [[NSMutableArray alloc] init];
    sessions = [[SessionStore defaultStore] sessions];
    [historyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [historyTableView setBackgroundColor:[UIColor clearColor]];
    for (Session *s in [sessions reverseObjectEnumerator])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        [sessionDates addObject:[dateFormat stringFromDate:[s date]]];
        [sessionTimes addObject: [NSString timeStringFromInt:[s calculateTotalTime]]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setContainerCenter:[self.parentViewController.view center]];  
}

- (void)presentDatePicker:(UIButton *)button
{
    [self.view bringSubviewToFront:datePicker];
    ContainerViewController *cvc = (ContainerViewController *)[self parentViewController];
    StatsVC *svc = [[cvc viewControllers] objectAtIndex:0];
    if ([self historyTableView ].center.y == [self view].center.y)
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            //[parentView setCenter:CGPointMake(containerCenter.x, containerCenter.y + datePicker.frame.size.height)];
            [[self historyTableView] setCenter:CGPointMake(historyTableView.center.x, historyTableView.center.y + datePicker.frame.size.height)];
            [datePicker setFrame:CGRectMake(0, 0, datePicker.frame.size.width, datePicker.frame.size.height)];
            [svc.view setCenter:CGPointMake(svc.view.center.x, historyTableView.center.y)];
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            [[self historyTableView] setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
            [datePicker setFrame:CGRectMake(0, -datePicker.frame.size.height, datePicker.frame.size.width, datePicker.frame.size.height)];
            [svc.view setCenter:CGPointMake(svc.view.center.x, self.view.center.y)];
        } completion:^(BOOL finished) {
            [self slideToDate:[datePicker date]];
        }];
    }
}
- (void)slideToDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    NSString *selectedDate = [dateFormat stringFromDate:date];
    BOOL didntFindSession = YES;
    for (int i = 0; i < [sessionDates count]; i++)
    {
        if ([[sessionDates objectAtIndex:i] isEqualToString:selectedDate])
        {
            [historyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
            didntFindSession = NO;
        }
    }
    if (didntFindSession)
    {
        UIImageView *noSession = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUD.png"]];
        [noSession setCenter:CGPointMake(160, 220)];
        [noSession setAlpha:0];
        UILabel *text = [[UILabel alloc] init];
        [text setBounds:CGRectMake(0, 0, 90, 80)];
        [text setCenter:CGPointMake(noSession.frame.size.width/2, noSession.frame.size.height/2)];
        [text setNumberOfLines:0];
        [text setText:@"No practice found on this date."];
        [text setFont:[UIFont systemFontOfSize:17]];
        [text setTextAlignment:UITextAlignmentCenter];
        [text setBackgroundColor:[UIColor clearColor]];
        [text setTextColor:[UIColor whiteColor]];
        [noSession addSubview:text];
        [self.view addSubview:noSession];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [noSession setAlpha:1.0];
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5 delay:0.8 options:0 animations:^{
                                 [noSession setAlpha:0.0];
                             } completion:^(BOOL finished) {
                                 [noSession removeFromSuperview];
                             }];
                         }];

    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[SessionStore defaultStore] sessions] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [chooseDateButton setFrame:CGRectMake(0, 0, 30, 50)];
    [chooseDateButton setCenter:dateView.center];
    [chooseDateButton setBackgroundColor:[UIColor blueColor]];
    [dateView addSubview:chooseDateButton];
    [dateView setBackgroundColor:[UIColor whiteColor]];
    
    return dateView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell;
    cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (cell == nil) 
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    [cell updateTitle:[sessionDates objectAtIndex:[indexPath row]] subTitle:[sessionTimes objectAtIndex:[indexPath row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContainerViewController *cvc = (ContainerViewController *)[self parentViewController];
    StatsVC *svc = [[cvc viewControllers] objectAtIndex:0];
    NSArray *s = [[SessionStore defaultStore] sessions];
    NSInteger chronoIndex = [s count] - [indexPath row] - 1;
    [svc showStatsAtIndex:chronoIndex];
}

@end
