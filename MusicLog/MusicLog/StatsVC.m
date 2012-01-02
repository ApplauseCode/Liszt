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

@property (nonatomic, strong)   Timer *scaleTimer;
@property (nonatomic, strong)   Timer *arpeggioTimer;
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

- (void)makeMenu;
- (void) makeMetronome;
- (void) setUpScalesAndArpeggios;
- (void)tempoTimerFireMethod:(NSTimer*)aTimer;
- (double)chooseBPM:(double)bpm;
- (void)dateChanged;
- (void)hideMenu:(id)sender;

@end

@implementation StatsVC

@synthesize tempoLabel, metronomeView, timerView, metroTimeScroll, scrollPage, startTimer, timerDisplay, statsTable;
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
    [self setTimerDisplay:nil];
    [self setStartTimer:nil];
    [self setScrollPage:nil];
    [self setMetroTimeScroll:nil];
    [self setTimerView:nil];
    [self setMetronomeView:nil];
    [self setTempoLabel:nil];
    timerDisplay = nil;
    startTimer = nil;
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
    [metroTimeScroll setContentSize:CGSizeMake(640.0, 58)];
    [metroTimeScroll setShowsHorizontalScrollIndicator:NO];
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [statsTable reloadData];
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
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
}

#pragma mark - Actions

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
    //[scaleTimer changeTimeTo:[selectedSession scaleTime]];
    //[arpeggioTimer changeTimeTo:[selectedSession arpeggioTime]];
    [self setSelectedSession:[store mySession]];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
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
    [scaleTimer changeTimeTo:[selectedSession scaleTime]];
    [arpeggioTimer changeTimeTo:[selectedSession arpeggioTime]];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)myScrollView
{
    if ([myScrollView isEqual:metroTimeScroll]) 
    {
        CGFloat pageWidth = myScrollView.frame.size.width;
        int page = floor((myScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        scrollPage.currentPage = page;
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
    NSInteger numRowsInSection = [sectionInfo countofRowsToInsert];
    return sectionInfo.open ? numRowsInSection : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    ScalesPracticedCell *cell = (ScalesPracticedCell *) [tableView
                                                         dequeueReusableCellWithIdentifier:@"ScalesPracticedCell"];
    id entry;
    if (section == 0)
        entry = [[selectedSession scaleSession] objectAtIndex:[indexPath row]];
    else if (section == 1)
        entry = [[selectedSession arpeggioSession] objectAtIndex:[indexPath row]];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.headerView) 
    {
		NSString *sectionName = sectionInfo.title;
        sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 45) title:sectionName subTitle:@"" section:section delegate:self];
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

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    [scaleTimer disconnectTimers];
    [arpeggioTimer disconnectTimers];
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
         [[[[selectedSession pieceSession] objectAtIndex:i] timer] disconnectTimers];
    if (section == 0)
    {
            [scaleTimer setTimeButton:startTimer];
            [[scaleTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
            [scaleTimer setTimeLabel:timerDisplay];
    }
     else if (section == 1)
     {
            [arpeggioTimer setTimeButton:startTimer];
            [[arpeggioTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
            [arpeggioTimer setTimeLabel:timerDisplay];
    }
    else 
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [pieceTimer setTimeButton:startTimer];
        [[pieceTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
        [pieceTimer setTimeLabel:timerDisplay];
    }
    
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    sectionInfo.open = YES;
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [sectionInfo countofRowsToInsert]; i++) 
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
        [previousOpenSection.headerView setSubTitle:time];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
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
        [[scaleTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
        [scaleTimer stopTimer];
        time = [scaleTimer timeString];
        [[store mySession] setScaleTime:[scaleTimer elapsedTime]];
    }
    else if (section == 1)
    {
        [[arpeggioTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
        [arpeggioTimer stopTimer];
        time = [arpeggioTimer timeString];
        [[store mySession] setArpeggioTime:[arpeggioTimer elapsedTime]];
    }
    else
    {
        Timer *pieceTimer = [[[selectedSession pieceSession] objectAtIndex:(section - 2)] timer];
        [[pieceTimer timeButton] setTitle:@"Start" forState:UIControlStateNormal];
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

- (void)valueChanged
{
    [metro changeTempoWithTempo:[stepper tempo]];
}
@end
