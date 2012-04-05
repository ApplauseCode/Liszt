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
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    
    //[sessionDates addObject:[dateFormat stringFromDate:[myS date]]];
    [sessionDates addObject:[NSString convertDateToString:[myS date]]];
    [sessionTimes addObject:[NSString timeStringFromInt:[myS calculateTotalTime]]];
    for (Session *s in [sessions reverseObjectEnumerator])
    {
        [sessionDates addObject:[NSString convertDateToString:[s date]]];
        [sessionTimes addObject: [NSString timeStringFromInt:[s calculateTotalTime]]];
    }
    [historyTableView reloadData];

}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//	//This of course can be whatever array you need to pass back
//	//even for different table views, etc.
//	NSArray *arrIndexes = [NSArray arrayWithArray:
//                           [@"Jan,Feb,March,April,May,June,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,#"
//                            componentsSeparatedByString:@","]];
//	return arrIndexes;
//}



//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
 //   NSDate *firstSessionDate = [[[[SessionStore defaultStore] sessions] objectAtIndex:0] date];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDate *fromDate;
//    NSDate *toDate;
//    [cal rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
//            interval:NULL forDate:firstSessionDate];
//    [cal rangeOfUnit:NSDayCalendarUnit startDate:&toDate
//            interval:NULL forDate:[NSDate date]];
//    
//    NSDateComponents *difference = [cal components:NSMonthCalendarUnit
//                                          fromDate:fromDate toDate:toDate options:0];
//    return [difference month];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSArray *months = [NSArray arrayWithObjects:@"J", @"F", @"M", @"A", @"M", @"J", @"J", @"A", @"S", @"O", @"N", @"D", nil];
//    return months;
//}
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
    //UILabel *l = [[UILabel 
//    [cell.textLabel setText:[sessionDates objectAtIndex:[indexPath row]]];
//    [cell.textLabel setCenter:CGPointMake(cell.textLabel.center.x + 50, cell.textLabel.center.y)];
//    [cell.detailTextLabel setText:[sessionTimes objectAtIndex:[indexPath row]]];
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
