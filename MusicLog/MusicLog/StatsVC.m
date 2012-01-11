//
//  Calender.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "StatsVC.h"
#import "ScalePickerVC.h"
#import "PiecesPickerVC.h"
#import "ScaleStore.h"
#import "Session.h"
#import "NSString+Number.h"
#import "ScalesPracticedCell.h"
#import "Scale.h"
#import "Piece.h"
#import "SectionHeaderView.h"
#import "SectionInfo.h"
#import "Timer.h"
#import "CustomStepper.h"
#import "TimerCell.h"
#import "Metronome.h"

#pragma mark - Private Interface

@interface StatsVC ()

@property (nonatomic)           NSUInteger tempo;
@property (nonatomic, strong)   AVAudioPlayer *tickPlayer;
@property (nonatomic, strong)   CustomStepper *stepper;
@property (nonatomic, strong)   Session *selectedSession;
@property (nonatomic)           NSUInteger selSessionNum;
@property (nonatomic, strong)   NSMutableArray *filteredSessions;
@property (nonatomic)           BOOL currentPractice;
@property (nonatomic, strong)   UIDatePicker *datePicker;
@property (nonatomic, strong)   UITapGestureRecognizer *tapAwayGesture;
@property (nonatomic, strong)   UIView *greyMask;
@property (nonatomic, strong)   NSMutableArray* sectionInfoArray;
@property (nonatomic, assign)   NSInteger openSectionIndex;
@property (nonatomic, strong)   Metronome *metro;
@property (nonatomic, strong)   TimerCell *tCell;

- (void)makeMenu;
- (void)makeMetronome;
- (void)setUpScalesAndArpeggios;
- (void)dateChanged;
- (void)hideMenu:(id)sender;
- (void)changeTimeForTimers;
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;
@end

@implementation StatsVC
@synthesize tempoLabel, metronomeView, timerButton, statsTable;
@synthesize selSessionDisplay, chooseDateButton, myPopover, chooseScalesButton, chooseArpsButton, choosePiecesButton;
@synthesize scaleTimer;
@synthesize arpeggioTimer;
@synthesize tempo;
@synthesize tickPlayer;
@synthesize stepper;
@synthesize selectedSession;
@synthesize selSessionNum;
@synthesize filteredSessions;
@synthesize currentPractice;
@synthesize datePicker;
@synthesize tapAwayGesture;
@synthesize greyMask;
@synthesize sectionInfoArray;
@synthesize openSectionIndex;
@synthesize metro;
@synthesize tCell;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setChoosePiecesButton:nil];
    [self setChooseArpsButton:nil];
    [self setChooseScalesButton:nil];
    [self setMyPopover:nil];
    [self setChooseDateButton:nil];
    [self setSelSessionDisplay:nil];
    [self setStatsTable:nil];
    [self setTimerButton:nil];
    [self setMetronomeView:nil];
    [self setTempoLabel:nil];
    self.sectionInfoArray = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedSession = [[ScaleStore defaultStore] mySession];
        scaleTimer = [[Timer alloc] initWithElapsedTime:[selectedSession scaleTime]];
        arpeggioTimer = [[Timer alloc] initWithElapsedTime:[selectedSession arpeggioTime]];
        currentPractice = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // break up into smaller methods
    UINib *nib = [UINib nibWithNibName:@"ScalesPracticedCell" bundle:nil];
    [statsTable registerNib:nib 
     forCellReuseIdentifier:@"ScalesPracticedCell"];
    UINib *timerNib = [UINib nibWithNibName:@"TimerCell" bundle:nil];
    [statsTable registerNib:timerNib
     forCellReuseIdentifier:@"TimerCell"];
    
    tCell = (TimerCell *) [statsTable
                                      dequeueReusableCellWithIdentifier:@"TimerCell"];
    timerButton = [tCell timerButton];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, -216.0, 320, 253)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.view addSubview:datePicker];
    
    [self makeMenu];
    [self makeMetronome];
    [self setUpScalesAndArpeggios];
}

- (void) makeMenu {
    myPopover = [[[NSBundle mainBundle] loadNibNamed:@"CustomPopover" owner:self options:nil] objectAtIndex:0];
    [myPopover setFrame:CGRectMake(200, 55, 108, 145)];
    [myPopover setAlpha:0];
    tapAwayGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu:)];
    [tapAwayGesture setDelegate:self];
    [self.view addGestureRecognizer:tapAwayGesture];
    [tapAwayGesture setEnabled:NO];
    greyMask = [[UIView alloc] initWithFrame:[self.view frame]];
    [greyMask setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
    [greyMask setAlpha:0];
}

- (void) makeMetronome {
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(224, 15) andLabel:tempoLabel];
    [stepper setDelegate:self];
    [metronomeView addSubview:stepper];
    openSectionIndex = NSNotFound;
    metro = [[Metronome alloc] init];
}

- (void) setUpScalesAndArpeggios {
    if (self.sectionInfoArray == nil)
    {
        SectionInfo *sectionZero = [[SectionInfo alloc] init];
        [sectionZero setOpen:NO];
        [sectionZero setTitle:@"Scales"];
        SectionInfo *sectionOne = [[SectionInfo alloc] init];
        [sectionOne setOpen:NO];
        [sectionOne setTitle:@"Arpeggios"];
        sectionInfoArray = [NSMutableArray arrayWithObjects:sectionZero, sectionOne, nil];
        for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
        {
            SectionInfo *pieceInfo = [[SectionInfo alloc] init];
            [pieceInfo setTitle:[[[selectedSession pieceSession] objectAtIndex:i] title]];
            [pieceInfo setCountofRowsToInsert:1];
            [sectionInfoArray addObject:pieceInfo];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (int i = ([sectionInfoArray count] - 2); i < [[selectedSession pieceSession] count]; i++)
    {
        SectionInfo *pieceInfo = [[SectionInfo alloc] init];
        [pieceInfo setTitle:[[[selectedSession pieceSession] objectAtIndex:i] title]];
        [pieceInfo setCountofRowsToInsert:1];
        [sectionInfoArray addObject:pieceInfo];
    }
    [self changeTimeForTimers];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
}

#pragma mark - View Actions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == myPopover) || (touch.view == chooseScalesButton) || (touch.view == chooseArpsButton) || (touch.view == choosePiecesButton))
        return NO;
    return YES;
}

- (void)showMenu:(id)sender
{
    [self.view addSubview:greyMask];
    [self.view addSubview:myPopover];
    [UIView animateWithDuration:0.2 animations:^{
        [greyMask setAlpha:0.2];
        [myPopover setAlpha:1.0];
    }];
    [tapAwayGesture setEnabled:YES];
    for (SectionInfo *info in sectionInfoArray)
        [[[info headerView] tapGesture] setEnabled:NO];
}

- (void)hideMenu:(id)sender
{
    [myPopover removeFromSuperview];
    [myPopover setAlpha:0];
    [greyMask removeFromSuperview];
    [greyMask setAlpha:0];
    [tapAwayGesture setEnabled:NO];
    for (SectionInfo *info in sectionInfoArray)
        [[[info headerView] tapGesture] setEnabled:YES];
}

- (void)slideDown:(id)sender
{
    //calculate rect size not hard coded
    if ([datePicker frame].origin.y < -215.0)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [datePicker setFrame:CGRectMake(0.0, 10.0, 320, 253)];
            [chooseDateButton setFrame:CGRectMake(124, 226, 72, 37)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                [datePicker setFrame:CGRectMake(0.0, -12, 320, 253)];
                [chooseDateButton setFrame:CGRectMake(124, 204, 72, 37)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                    [datePicker setFrame:CGRectMake(0.0, 0.0, 320, 253)];
                    [chooseDateButton setFrame:CGRectMake(124, 216, 72, 37)];
                } completion:^(BOOL finished) {
                    [chooseDateButton setTitle:@"Done" forState:UIControlStateNormal];
                }];
            }];
        }];
    }
    else if ([datePicker frame].origin.y > -1.0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [datePicker setFrame:CGRectMake(0.0, -216.0, 320, 253)];
            [chooseDateButton setFrame:CGRectMake(124, 10, 72, 37)];
        }completion:^(BOOL finished) {
            [chooseDateButton setTitle:@"Date" forState:UIControlStateNormal];
            [self dateChanged];
        }];
    }
}

#pragma mark - Model Actions

- (void)valueChanged
{
    [metro changeTempoWithTempo:[stepper tempo]];
}

- (void)addScales:(id)sender
{
    ScalePickerVC *s = [[ScalePickerVC alloc] initWithIndex:0];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:s];
    [self presentModalViewController:nav animated:YES];
}

- (void)addArpeggios:(id)sender
{
    ScalePickerVC *a = [[ScalePickerVC alloc] initWithIndex:1];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:a];
    [self presentModalViewController:nav animated:YES];
}

- (void)addPieces:(id)sender
{
    PiecesPickerVC *p = [[PiecesPickerVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:p];
    [self presentModalViewController:nav animated:YES];
}

- (void)newSession:(id)sender
{
    ScaleStore *store = [ScaleStore defaultStore];
    [[store mySession] setScaleTime:[scaleTimer elapsedTime]];
    [[store mySession] setArpeggioTime:[arpeggioTimer elapsedTime]];
    for (Piece *p in [[store mySession] pieceSession])
        [p setPieceTime:[[p timer] elapsedTime]];
    [store addSession];
    [scaleTimer resetTimer];
    [arpeggioTimer resetTimer];
    [self setSelectedSession:[store mySession]];
    [sectionInfoArray removeObjectsInRange:NSMakeRange(2, ([sectionInfoArray count] - 2))];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:0];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:0];
    [statsTable reloadData];
}

- (void)changeTimeForTimers
{
    if (scaleTimer)
        [scaleTimer changeTimeTo:[selectedSession scaleTime]];
    else
    {
        Timer *s = [[Timer alloc] initWithElapsedTime:[selectedSession scaleTime]];
        scaleTimer = s;
    }
    
    if (arpeggioTimer)
        [arpeggioTimer changeTimeTo:[selectedSession arpeggioTime]];
    else
    {
        Timer *a = [[Timer alloc] initWithElapsedTime:[selectedSession arpeggioTime]];
        arpeggioTimer = a;
    }
    
    for (Piece *p in [selectedSession pieceSession])
    {
        if ([p timer])
            [[p timer] changeTimeTo:[p pieceTime]];
        else
        {
            Timer *t = [[Timer alloc] initWithElapsedTime:[p pieceTime]];
            [p setTimer:t];
        }
    }
}

- (void)dateChanged
{
    // deal with picking today
    NSArray *sessions = [[ScaleStore defaultStore] sessions];    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[datePicker date]];
    NSDate *today = [cal dateFromComponents:components];
    filteredSessions = [[NSMutableArray alloc] initWithCapacity:1];
    
    [sessions enumerateObjectsUsingBlock:^(Session *obj, NSUInteger idx, BOOL *stop) {
        NSDateComponents *newComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[obj date]];
        NSDate *chosenDate = [cal dateFromComponents:newComponents];
        if ([chosenDate isEqualToDate:today])
        {
            [filteredSessions addObject:[obj copy]];
            selSessionNum = idx;
        }
    }];
    
    if ((filteredSessions == nil) || ([filteredSessions count] == 0))
    {
        [selSessionDisplay setText:@"No Sessions From This Date"];
        selectedSession = [[ScaleStore defaultStore] mySession];
        currentPractice = YES;
    }
    else
    {
        selectedSession = [filteredSessions objectAtIndex:0];
        [selSessionDisplay setText:[NSString stringWithFormat:@"Session %i, Created on %@", selSessionNum, [selectedSession date]]];
        currentPractice = NO;
    }
    [self changeTimeForTimers];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    for (int i = ([sectionInfoArray count] - 2); i < [[selectedSession pieceSession] count]; i++)
    {
        SectionInfo *pieceInfo = [[SectionInfo alloc] init];
        [pieceInfo setTitle:[[[selectedSession pieceSession] objectAtIndex:i] title]];
        [pieceInfo setCountofRowsToInsert:1];
        [sectionInfoArray addObject:pieceInfo];
    }
    [statsTable reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    SectionInfo *sec;
    if ([scaleTimer isTiming])
    {
        sec = [sectionInfoArray objectAtIndex:0];
        [scaleTimer setTimeLabel:[sec.headerView subTitleLabel]];
    }
    else if ([arpeggioTimer isTiming])
    {
        sec = [sectionInfoArray objectAtIndex:1];
        [arpeggioTimer setTimeLabel:[sec.headerView subTitleLabel]];
    }
    else
    {
        for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
        {
            Piece *p = [[selectedSession pieceSession] objectAtIndex:i];
            Timer *t = [p timer];
            if ([t isTiming])
            {
                SectionInfo *s = [sectionInfoArray objectAtIndex:i + 2];
                [t setTimeLabel:[s.headerView subTitleLabel]];
            }
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (2 + [[selectedSession pieceSession] count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSInteger numRowsInSection = [sectionInfo countofRowsToInsert] + 1;
    return sectionInfo.open ? numRowsInSection : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if ((!sectionInfo.headerView) || (section == 0) || (section == 1)) 
    {
		NSString *sectionName = sectionInfo.title;
        sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 45) title:sectionName subTitle:@"woops" section:section delegate:self];
        NSString *time;
        if (section ==  0)
        {
            time = [scaleTimer timeString];
            
        }
        else if (section == 1)
        {
            time = [arpeggioTimer timeString];
        }
        else
        {
            time = [[[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer] timeString];
        }
        [sectionInfo.headerView setSubTitle:time];
    }
    return sectionInfo.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    ScalesPracticedCell *cell = (ScalesPracticedCell *) [tableView
                                                         dequeueReusableCellWithIdentifier:@"ScalesPracticedCell"];

    if (row == 0)
    {
        return tCell;
    }
    id entry;
    if (section == 0)
        entry = [[selectedSession scaleSession] objectAtIndex:([indexPath row] - 1)];
    else if (section == 1)
        entry = [[selectedSession arpeggioSession] objectAtIndex:([indexPath row] - 1)];
    if (section < 2)
    {
        cell.tonicLabel.text = [entry tonicString];
        cell.modeLabel.text = [entry modeString];
        cell.rhythmLabel.text = [entry rhythmString];
        cell.speedLabel.text = [entry tempoString];
        cell.octavesLabel.text = [entry octavesString];
    }
    else
    {
        entry = [[selectedSession pieceSession] objectAtIndex:([indexPath section] - 2)];
        cell.tonicLabel.text = [entry title];
        cell.modeLabel.text = [entry composer];
        cell.rhythmLabel.text = [entry keyString];
        cell.speedLabel.text = [NSString stringWithInt:[entry opus]];
        if ([entry major])
            cell.octavesLabel.text = @"Major";
        else
            cell.octavesLabel.text = @"Minor";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    return cell;
}

#pragma mark - Handling Sections

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView tapped:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.open)
        [self sectionHeaderView:sectionHeaderView sectionOpened:section];
    else
        [self sectionHeaderView:sectionHeaderView sectionClosed:section];
}

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [scaleTimer disconnectTimers];
    [arpeggioTimer disconnectTimers];
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
        [[[[selectedSession pieceSession] objectAtIndex:i] timer] disconnectTimers];
    if (section == 0)
    {
        [scaleTimer setTimeButton:timerButton];
        [[scaleTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
        [scaleTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    else if (section == 1)
    {
        [arpeggioTimer setTimeButton:timerButton];
        [[arpeggioTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
        [arpeggioTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    else 
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [pieceTimer setTimeButton:timerButton];
        [[pieceTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal]; 
        [pieceTimer setTimeLabel:[sectionInfo.headerView subTitleLabel]];
    }
    sectionInfo.open = YES;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:0 inSection:section]];
    for (NSInteger i = 1; i <= [sectionInfo countofRowsToInsert]; i++) 
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    
    
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        NSString *time;
        if (previousOpenSectionIndex == 0)
        {
            [[scaleTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
            [scaleTimer stopTimer];
            time = [scaleTimer timeString];
        }
        else if (previousOpenSectionIndex == 1)
        {
            [[arpeggioTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
            [arpeggioTimer stopTimer];
            time = [arpeggioTimer timeString];
        }
        else
        {
            Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(previousOpenSectionIndex - 2)] timer];
            [[pieceTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
            [pieceTimer stopTimer];
            time = [pieceTimer timeString];
        }
        
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenSectionIndex]];
        [previousOpenSection.headerView setSubTitle:time];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        for (NSInteger i = 1; i <= countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
    
    self.openSectionIndex = section;
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    NSString *time;
    ScaleStore *store = [ScaleStore defaultStore];
    if (section == 0)
    {
        [scaleTimer stopTimer];
        time = [scaleTimer timeString];
        [[store mySession] setScaleTime:[scaleTimer elapsedTime]];
    }
    else if (section == 1)
    {
        [arpeggioTimer stopTimer];
        time = [arpeggioTimer timeString];
        [[store mySession] setArpeggioTime:[arpeggioTimer elapsedTime]];
    }
    else
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [pieceTimer stopTimer];
        time = [pieceTimer timeString];
    }
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo.headerView setSubTitle:time];
    sectionInfo.open = NO;
    NSInteger countofRowsToDelete = [statsTable numberOfRowsInSection:section];
    
    if (countofRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countofRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        [statsTable beginUpdates];
        [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
        [statsTable endUpdates];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)startMetronome:(id)sender {
    [metro startMetronomeWithTempo:[stepper tempo]];
    if ([[sender currentTitle] isEqualToString: @"Start"])
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    else if ([[sender currentTitle] isEqualToString:@"Stop"])
        [sender setTitle:@"Start" forState:UIControlStateNormal];
}
@end
