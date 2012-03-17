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

@end

@implementation StatsVC
@synthesize totalTime;
@synthesize addButton;
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
@synthesize sectionMover;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setAddButton:nil];
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

////////////////////////// REMOVE LATER //////////////////

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    stopWatch = [[StopWatch alloc] init];
    isTiming = NO;
    
    [selSessionDisplay setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [selSessionDisplay setTextColor:[UIColor whiteColor]];

    UINib *nib = [UINib nibWithNibName:@"ScalesPracticedCell" bundle:nil];
    [statsTable registerNib:nib 
     forCellReuseIdentifier:@"ScalesPracticedCell"];
    [statsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    totalTime = [[UILabel alloc] initWithFrame:CGRectMake(239, 57, 100, 28)];
    [totalTime setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [totalTime setTextColor:[UIColor blackColor]];
    [totalTime setBackgroundColor:[UIColor clearColor]];
    NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
    [totalTime setText:timeString];
    [self.view addSubview:totalTime];
    
    todayButton = [[UIButton alloc] initWithFrame:CGRectMake(160-(139*1/2), 460, 139, 60)];
    [todayButton setImage:[UIImage imageNamed:@"backToTodayButton.png"] forState:UIControlStateNormal];
    [todayButton addTarget:self action:@selector(backToToday:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:todayButton];

    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, -216.0, 320, 253)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMaximumDate:[NSDate date]];
    [self.view addSubview:datePicker];
    
    UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:12];

    [tempoNameLabel setFont:caslon];
    [tempoNameLabel setText:@"METRONOME:"];
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
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(215, -6) label:tempoLabel andCanBeNone:NO];
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

////////////////////// REMOVE LATER ////////////////////////

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        [TestFlight openFeedbackView];
}

///////////////////////////////////////////////////////////

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
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            [datePicker setFrame:CGRectMake(0.0, 0.0, 320, 253)];
            [chooseDateButton setCenter:CGPointMake(center.x, center.y + 210)];
        } completion:^(BOOL finished) {
        }];
        
    }
    else if ([datePicker frame].origin.y > -1.0)
    {
        [UIView animateWithDuration:0.35 animations:^{
            [datePicker setFrame:CGRectMake(0.0, -216.0, 320, 253)];
            [chooseDateButton setCenter:CGPointMake(center.x, center.y - 210)];
        }completion:^(BOOL finished) {
            [self dateChanged];
        }];
    }
}

#pragma mark - Model Actions

- (NSInteger)calculateTotalTime
{
    NSInteger total = 0;
    
    total += [selectedSession scaleTime];
    total += [selectedSession arpeggioTime];
    for (Piece *p in [selectedSession pieceSession])
        total += [p pieceTime];
    return total;
}

- (void)timerButtonPressed:(id)sender
{
    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StartTimer.png"]])
        [sender setImage:[UIImage imageNamed:@"StopTimer.png"] forState:UIControlStateNormal];
    else if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StopTimer.png"]])
        [sender setImage:[UIImage imageNamed:@"StartTimer.png"] forState:UIControlStateNormal];
    [self toggleTimer:openSectionIndex];
}

- (void)toggleTimer:(int)section
{
    id observer = [[SessionStore defaultStore] mySession];
    NSString *context;
    if (section == 0)
        context = @"scaleTime";
    else if (section == 1)
        context = @"arpeggioTime";
    else
    {
        context = @"pieceTime";
        observer = [[observer pieceSession] objectAtIndex:(section - 2)];
    }
    if (!isTiming)
    {
        [stopWatch addObserver:observer forKeyPath:@"totalSeconds" options:NSKeyValueObservingOptionNew context:(__bridge void *)context];
        [observer addObserver:self
                    forKeyPath:context
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        
        [self setTheObserver:observer];
        [self setIsTiming:YES];
    }
    else
    {
        [stopWatch removeObserver:observer forKeyPath:@"totalSeconds" context:(__bridge void *)context];
        [observer removeObserver:self forKeyPath:context];
        [self setTheObserver:nil];
        [self setIsTiming:NO];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
    [totalTime setText:timeString];
    [statsTable reloadData];

}

- (void)valueChanged
{
    [metro changeTempoWithTempo:[stepper tempo]];
}

- (void)blockAlertView:(BOOL)isYes
{
    [[self datePicker] setMaximumDate:[NSDate date]];
    [[self datePicker] setDate:[NSDate date]];
    SessionStore *store = [SessionStore defaultStore];
    [store addSessionStartNew:isYes];
    if (isYes)
        [sectionInfoArray removeObjectsInRange:NSMakeRange(2, ([sectionInfoArray count] - 2))];
    [self setSelectedSession:[store mySession]];
    
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
        [[[sectionInfoArray objectAtIndex:i + 2] headerView] setSubTitle:[NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:i] pieceTime]]];
    [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    [statsTable reloadData];
    NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
    [totalTime setText:timeString];
}

- (void)backToToday:(id)sender
{
    [datePicker setDate:[NSDate date]];
    [self dateChanged];
}

- (void)dateChanged
{
    NSMutableArray *sessions = [[SessionStore defaultStore] sessions];    
    [self closeSections]; 
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
        [selSessionDisplay setText:@"Current Practice"];
        selectedSession = [[SessionStore defaultStore] mySession];
        currentPractice = YES;
        NSDateComponents *compare = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        if (![today isEqualToDate:[cal dateFromComponents:compare]])
        {
            [datePicker setDate:[NSDate date]];
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
    else
    {
        selectedSession = [filteredSessions objectAtIndex:0];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        [selSessionDisplay setText:[dateFormat stringFromDate:[selectedSession date]]];
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
    NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
    [totalTime setText:timeString];
    
    float metronomeCenter = self.view.frame.size.height - [metronomeView bounds].size.height / 2.0;
    float metronomeHeight = [metronomeView bounds].size.height;
    float metronomePosition = metronomeCenter;
    float buttonHeight = [addButton bounds].size.height;
    float buttonCenterY = currentPractice ? buttonHeight / 2.0 + 6 : -buttonHeight / 2.0 - 6;
    metronomePosition += currentPractice ? 0 : metronomeHeight;
    float todayCenterY = currentPractice ? metronomeCenter + metronomeHeight : metronomeCenter;
    float aDelay = currentPractice ? 0.3 : 0.0;
    [UIView animateWithDuration:0.3 
                          delay:aDelay 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
                         [metronomeView setCenter:CGPointMake([metronomeView center].x,metronomePosition)];
                         [addButton setCenter:CGPointMake([addButton center].x, buttonCenterY)];}
                     completion:nil];
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
    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StartMetronomeButton.png"]])
        [sender setImage:[UIImage imageNamed:@"StopButton.png"] forState:UIControlStateNormal];
    else if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StopButton.png"]])
        [sender setImage:[UIImage imageNamed:@"StartMetronomeButton.png"] forState:UIControlStateNormal];
}
@end
