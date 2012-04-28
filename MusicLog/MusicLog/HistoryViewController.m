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
#import "InfoViewController.h"

@interface HistoryViewController ()

@property (nonatomic, strong) NSMutableArray *sessionDates;
@property (nonatomic, strong) NSMutableArray *sessionTimes;
@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) IBOutlet UITableView *historyTableView;
@property (nonatomic, assign) NSInteger selectedCellIndex;
- (IBAction)presentInfoScreen:(id)sender;
@end

@implementation HistoryViewController
@synthesize forwardYearButton;
@synthesize forwardMonthButton;
@synthesize todayButton;
@synthesize backYearButton;
@synthesize backMonthButton;
@synthesize sessionTimes;
@synthesize sessionDates;
@synthesize sessions;
@synthesize historyTableView;
@synthesize selectedCellIndex;

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
    UIFont *italic = [UIFont fontWithName:@"ACaslonPro-Italic" size:20];
    [forwardYearButton.titleLabel setFont:italic];
    [forwardMonthButton.titleLabel setFont:italic];
    [todayButton.titleLabel setFont:italic];
    [backMonthButton.titleLabel setFont:italic];
    [backYearButton.titleLabel setFont:italic];
    
    [historyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [historyTableView setBackgroundColor:[UIColor clearColor]];
    [self loadData];
}

- (void)reloadFirstCell
{
    Session *myS = [[SessionStore defaultStore] mySession];
    [sessionTimes replaceObjectAtIndex:0 withObject:[NSString timeStringFromInt:[myS calculateTotalTime]]];
    [historyTableView reloadData];
    
}

- (void)loadData
{
    sessionDates = [[NSMutableArray alloc] init];
    sessionTimes = [[NSMutableArray alloc] init];
    sessions = [[SessionStore defaultStore] sessions];

    Session *myS = [[SessionStore defaultStore] mySession];
    [sessionDates addObject:[NSString convertDateToString:[myS date]]];
    [sessionTimes addObject:[NSString timeStringFromInt:[myS calculateTotalTime]]];
    for (Session *s in [sessions reverseObjectEnumerator])
    {
        [sessionDates addObject:[NSString convertDateToString:[s date]]];
        [sessionTimes addObject: [NSString timeStringFromInt:[s calculateTotalTime]]];
    }
    [historyTableView reloadData];

}

- (void)viewDidUnload
{
    [self setBackMonthButton:nil];
    [self setBackYearButton:nil];
    [self setTodayButton:nil];
    [self setForwardMonthButton:nil];
    [self setForwardYearButton:nil];
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
    return [[[SessionStore defaultStore] sessions] count] + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryCell *cell;
    cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (cell == nil) 
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    if ([indexPath row] == self.selectedCellIndex)
    {
        [cell selectCell:YES];
    }
    else
    {
        [cell selectCell:NO];
    }
    [cell updateTitle:[sessionDates objectAtIndex:[indexPath row]] subTitle:[sessionTimes objectAtIndex:[indexPath row]]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (HistoryCell *hc in [historyTableView visibleCells])
    {
        [hc selectCell:NO];
    }
    [(HistoryCell *)[historyTableView cellForRowAtIndexPath:indexPath] selectCell:YES];
    [self setSelectedCellIndex:[indexPath row]];
    ContainerViewController *cvc = (ContainerViewController *)[self parentViewController];
    StatsVC *svc = [[cvc viewControllers] objectAtIndex:0];
    NSArray *s = [[SessionStore defaultStore] sessions];
    NSInteger chronoIndex = [s count] - [indexPath row];
    [svc showStatsAtIndex:chronoIndex];
}

- (IBAction)backOneYear:(id)sender 
{
    NSArray *s = [[SessionStore defaultStore] sessions];
    int c = [s count];
    NSIndexPath *path = [[historyTableView indexPathsForVisibleRows] objectAtIndex:0];
    NSUInteger row = path.row + 365;
    row = (row > c - 1) ? c -1 : row;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES];
}

- (IBAction)forwardOneYear:(id)sender 
{
    //NSArray *s = [[SessionStore defaultStore] sessions];
    //int c = [s count];
    NSIndexPath *path = [[historyTableView indexPathsForVisibleRows] objectAtIndex:0];
    NSInteger row = path.row - 365;
    row = (row < 0) ? 0 : row;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES];
}

- (IBAction)backOneMonth:(id)sender 
{
    NSArray *s = [[SessionStore defaultStore] sessions];
    int c = [s count];
    NSIndexPath *path = [[historyTableView indexPathsForVisibleRows] objectAtIndex:0];
    NSUInteger row = path.row + 30;
    row = (row > c - 1) ? c -1 : row;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES];
}

- (IBAction)forwardOneMonth:(id)sender
{
    //NSArray *s = [[SessionStore defaultStore] sessions];
    //int c = [s count];
    NSIndexPath *path = [[historyTableView indexPathsForVisibleRows] objectAtIndex:0];
    NSInteger row = path.row - 30;
    row = (row < 0) ? 0 : row;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES]; 
}

- (IBAction)toToday:(id)sender 
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES];
}
- (IBAction)presentInfoScreen:(id)sender {
    InfoViewController *infoViewController = [[InfoViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
    [navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self presentModalViewController:navigationController animated:YES];
}
@end
