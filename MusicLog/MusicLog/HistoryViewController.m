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
@end

@implementation HistoryViewController
@synthesize sessionTimes;
@synthesize sessionDates;
@synthesize sessions;
@synthesize historyTableView;

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
    sessionDates = [[NSMutableArray alloc] init];
    sessionTimes = [[NSMutableArray alloc] init];
    sessions = [[SessionStore defaultStore] sessions];
    [historyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [historyTableView setBackgroundColor:[UIColor clearColor]];
    
    Session *myS = [[SessionStore defaultStore] mySession];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    
    [sessionDates addObject:[dateFormat stringFromDate:[myS date]]];
    [sessionTimes addObject:[NSString timeStringFromInt:[myS calculateTotalTime]]];
    for (Session *s in [sessions reverseObjectEnumerator])
    {
        [sessionDates addObject:[dateFormat stringFromDate:[s date]]];
        [sessionTimes addObject: [NSString timeStringFromInt:[s calculateTotalTime]]];
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

- (IBAction)toToday:(id)sender 
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [historyTableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:(BOOL)YES];
}
@end
