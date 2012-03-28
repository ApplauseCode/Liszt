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
    for (Session *s in [sessions reverseObjectEnumerator])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
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
//    [cell setTitleLabel:[sessionDates objectAtIndex:[indexPath row]]]; 
//    [cell setSubTitleLabel:[sessionTimes objectAtIndex:[indexPath row]]];
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
