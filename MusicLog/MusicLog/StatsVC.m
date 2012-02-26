//
//  StatsVC.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "StatsVC.h"
#import "ScalePickerVC.h"
#import "PiecesPickerVC.h"
#import "SessionStore.h"
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
#import "UIColor+YellowTextColor.h"
#import "BlockAlertView.h"
#import "StopWatch.h"

#pragma mark - Private Interface

@interface StatsVC ()

@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) StopWatch *stopWatch;
@property (nonatomic, strong) id theObserver;
- (void)backToToday:(id)sender;
- (void)blockAlertView:(BOOL)isYes;

@end

@implementation StatsVC
@synthesize addButton;
@synthesize aNewButton;
@synthesize tempoLabel, metronomeView, timerButton, statsTable;
@synthesize selSessionDisplay, chooseDateButton, myPopover, chooseScalesButton, chooseArpsButton, choosePiecesButton, tempoNameLabel;
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
@synthesize datePickerView;
@synthesize sectionInfoArray;
@synthesize openSectionIndex;
@synthesize metro;
@synthesize tCell;
@synthesize shouldDisplayTime;
@synthesize todayButton;
@synthesize stopWatch;
@synthesize theObserver;
@synthesize isTiming;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setAddButton:nil];
    [self setANewButton:nil];
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
        selectedSession = [[SessionStore defaultStore] mySession];
        currentPractice = YES;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    stopWatch = [[StopWatch alloc] init];
    isTiming = NO;

    UINib *nib = [UINib nibWithNibName:@"ScalesPracticedCell" bundle:nil];
    [statsTable registerNib:nib 
     forCellReuseIdentifier:@"ScalesPracticedCell"];
    UINib *timerNib = [UINib nibWithNibName:@"TimerCell" bundle:nil];
    [statsTable registerNib:timerNib
     forCellReuseIdentifier:@"TimerCell"];
    [statsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    todayButton = [[UIButton alloc] initWithFrame:CGRectMake(160-(139*1/2), 460, 139, 60)];
    [todayButton setImage:[UIImage imageNamed:@"backToTodayButton.png"] forState:UIControlStateNormal];
    [todayButton addTarget:self action:@selector(backToToday:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:todayButton];

    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, -216.0, 320, 253)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMaximumDate:[NSDate date]];
    [self.view addSubview:datePicker];
    
    UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:11];

    [tempoNameLabel setFont:caslon];
    [tempoNameLabel setText:@"TEMPO:"];
    [tempoNameLabel setTextColor:[UIColor yellowTextColor]];
    [self makeMenu];
    [self makeMetronome];
    [self setUpScalesAndArpeggios];
}

- (void) makeMenu {
    myPopover = [[[NSBundle mainBundle] loadNibNamed:@"CustomPopover" owner:self options:nil] objectAtIndex:0];
    [myPopover setFrame:CGRectMake(200, 47, 128, 150)];
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
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(215, -6) andLabel:tempoLabel];
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
        [sectionZero setTitle:@"scales"];
        SectionInfo *sectionOne = [[SectionInfo alloc] init];
        [sectionOne setOpen:NO];
        [sectionOne setTitle:@"arpeggios"];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
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
    [self hideMenu:nil];
}

#pragma mark - View Actions

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        [TestFlight openFeedbackView];
}

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
    [UIView animateWithDuration:0.2 animations:^{
        [myPopover setAlpha:0];
        [greyMask setAlpha:0];
    } completion:^(BOOL finished) {
        [myPopover removeFromSuperview];
        [greyMask removeFromSuperview];
    }];
    [tapAwayGesture setEnabled:NO];
    for (SectionInfo *info in sectionInfoArray)
        [[[info headerView] tapGesture] setEnabled:YES];
}

- (void)presentPickerView:(id)sender
{
    id vc;
    switch ([sender tag]) {
        case 0:
            vc = [[ScalePickerVC alloc] initWithIndex:0];
            break;
        case 1:
            vc = [[ScalePickerVC alloc] initWithIndex:1];
            break;
        case 2:
            vc = [[PiecesPickerVC alloc] init];
            break;
    }        
    [self presentModalViewController:vc animated:YES];
    [self closeSections];
}
- (void)slideDown:(id)sender
{
    CGPoint center = [chooseDateButton center];
    if ([datePicker frame].origin.y < -215.0)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            [datePicker setFrame:CGRectMake(0.0, 10.0, 320, 253)];
            [chooseDateButton setCenter:CGPointMake(center.x, center.y + 216)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                [datePicker setFrame:CGRectMake(0.0, -12, 320, 253)];
                [chooseDateButton setCenter:CGPointMake(center.x, center.y + 194)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                    [datePicker setFrame:CGRectMake(0.0, 0.0, 320, 253)];
                    [chooseDateButton setCenter:CGPointMake(center.x, center.y + 206)];
                } completion:^(BOOL finished) {
                }];
            }];
        }];
    }
    else if ([datePicker frame].origin.y > -1.0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [datePicker setFrame:CGRectMake(0.0, -216.0, 320, 253)];
            [chooseDateButton setCenter:CGPointMake(center.x, center.y - 206)];
        }completion:^(BOOL finished) {
            [self dateChanged];
        }];
    }
}

#pragma mark - Model Actions

- (void)timerButtonPressed:(id)sender
{
    [self toggleTimer:openSectionIndex];
}

- (void)toggleTimer:(int)section
{
    id observer = [[SessionStore defaultStore] mySession];
    NSString *context;
    if (section == 0)
        context = @"scales";
    else if (section == 1)
        context = @"arpeggios";
    else
    {
        context = @"piece";
        observer = [[observer pieceSession] objectAtIndex:(section - 2)];
    }
    if (!isTiming)
    {
        [stopWatch addObserver:observer forKeyPath:@"totalSeconds" options:NSKeyValueObservingOptionNew context:(__bridge void *)context];
        [self setTheObserver:observer];
        [self setIsTiming:YES];
    }
    else
    {
        [stopWatch removeObserver:observer forKeyPath:@"totalSeconds" context:(__bridge void *)context];
        [self setTheObserver:nil];
        [self setIsTiming:NO];
    }
}

- (void)valueChanged
{
    [metro changeTempoWithTempo:[stepper tempo]];
}

- (void)newSession:(id)sender
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *componentsForOld = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[selectedSession date]];
    NSDate *startDateOfPreviousSession = [cal dateFromComponents:componentsForOld];
    NSDateComponents *componentsForNow = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:componentsForNow];
    
    if ([startDateOfPreviousSession isEqualToDate:today])
    {
        BlockAlertView *whoops = [BlockAlertView alertWithTitle:@"Whoops!" message:@"You already have a session started today. Now get back to practicing!"];
        [whoops setDestructiveButtonWithTitle:@"Ok" block:nil];
        [whoops show];
        return;
    }
    BlockAlertView *newOrOld = [BlockAlertView alertWithTitle:@"New Session" message:@"Would you like to start this session as a copy of your previous session?"];
    [newOrOld addButtonWithTitle:@"No" block:^{
        [self blockAlertView:NO];
    }];
    [newOrOld addButtonWithTitle:@"Yes" block:^{
        [self blockAlertView:YES];
    }];
    [newOrOld setDestructiveButtonWithTitle:@"Cancel" block:nil];

    [newOrOld show];
   }

- (void)blockAlertView:(BOOL)isYes
{
    SessionStore *store = [SessionStore defaultStore];
    [store addSessionStartNew:isYes];
    if (isYes)
    {
    }
    else
        [sectionInfoArray removeObjectsInRange:NSMakeRange(2, ([sectionInfoArray count] - 2))];
    [self setSelectedSession:[store mySession]];
    
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
    {
        [[[sectionInfoArray objectAtIndex:i + 2] headerView] setSubTitle:[NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:i] pieceTime]]];
    }
    
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
}

- (void)backToToday:(id)sender
{
    [datePicker setDate:[NSDate date]];
    [self dateChanged];
}

- (void)dateChanged
{
    [self closeSections]; 
    NSArray *sessions = [[SessionStore defaultStore] sessions];    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[datePicker date]];
    NSDate *today = [cal dateFromComponents:components];
    filteredSessions = [[NSMutableArray alloc] initWithCapacity:1];
    
    [sessions enumerateObjectsUsingBlock:^(Session *obj, NSUInteger idx, BOOL *stop) {
        NSDateComponents *newComponents = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[obj date]];
        NSDate *chosenDate = [cal dateFromComponents:newComponents];
        if ([chosenDate isEqualToDate:today])
        {
            [filteredSessions addObject:[obj mutableCopy]];
            selSessionNum = idx;
        }
    }];
    
    if ((filteredSessions == nil) || ([filteredSessions count] == 0))
    {
        [selSessionDisplay setText:[NSString stringWithFormat:@"Current Session - started on: %@",[selectedSession date]]];
        selectedSession = [[SessionStore defaultStore] mySession];
        currentPractice = YES;
    }
    else
    {
        selectedSession = [filteredSessions objectAtIndex:0];
        [selSessionDisplay setText:[NSString stringWithFormat:@"Session %i, Created on %@", selSessionNum, [selectedSession date]]];
        currentPractice = NO;
    }
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [sectionInfoArray removeObjectsInRange:NSMakeRange(2, ([sectionInfoArray count] -2))];
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
    {
        SectionInfo *pieceInfo = [[SectionInfo alloc] init];
        [pieceInfo setTitle:[[[selectedSession pieceSession] objectAtIndex:i] title]];
        [pieceInfo setCountofRowsToInsert:1];
        [sectionInfoArray addObject:pieceInfo];
    }
    [statsTable reloadData];
    
    float metronomeCenter = self.view.frame.size.height - [metronomeView bounds].size.height / 2.0;
    float metronomeHeight = [metronomeView bounds].size.height;
    float metronomePosition = metronomeCenter;
    float buttonHeight = [aNewButton bounds].size.height;
    float buttonCenterY = currentPractice ? buttonHeight / 2.0 -3 : -buttonHeight / 2.0 - 3;
    metronomePosition += currentPractice ? 0 : metronomeHeight;
    float todayCenterY = currentPractice ? metronomeCenter + metronomeHeight : metronomeCenter;
    float aDelay = currentPractice ? 0.3 : 0.0;
    [UIView animateWithDuration:0.3 
                          delay:aDelay 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
                         [metronomeView setCenter:CGPointMake([metronomeView center].x,metronomePosition)];
                         [addButton setCenter:CGPointMake([addButton center].x, buttonCenterY)];
                         [aNewButton setCenter:CGPointMake([aNewButton center].x, buttonCenterY)];} completion:nil];
    [UIView animateWithDuration:0.3 
                          delay:0.3 - aDelay
                        options:0 
                     animations:^{[todayButton setCenter:CGPointMake([todayButton center].x, todayCenterY)];} 
                     completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     SectionInfo *openSection;
     NSNumber *index;
    for (int i = 0; i < [sectionInfoArray count]; i++)
    {
        SectionInfo *s = [sectionInfoArray objectAtIndex:i];
        if ([s open])
        {
            openSection = s;
            index = [NSNumber numberWithInt:i];
            break;
        }
        else
            index = nil;
    }
}

- (void)startMetronome:(id)sender {
    [metro startMetronomeWithTempo:[stepper tempo]];
    if ([[sender currentTitle] isEqualToString: @"Start"])
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    else if ([[sender currentTitle] isEqualToString:@"Stop"])
        [sender setTitle:@"Start" forState:UIControlStateNormal];
}
@end
