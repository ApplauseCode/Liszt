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
#import "LisztCell.h"
#import "ScaleCell.h"
#import "PieceCell.h"
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
#import "NotesVC.h"

#pragma mark - Private Interface

@interface StatsVC ()
@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIView *datePickerView;
@property (nonatomic, strong) StopWatch *stopWatch;
@property (nonatomic, strong) id theObserver;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIButton *slideBack;

- (void)backToToday:(id)sender;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
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
@synthesize swipedHeader;
@synthesize notesView;
@synthesize notesTapGesture;
@synthesize panGestureRecognizer;
@synthesize slideBack;

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
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
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
    
    [(StatsView *) self.view setDelegate:self];
    stopWatch = [[StopWatch alloc] init];
    isTiming = NO;
    [selSessionDisplay setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [selSessionDisplay setTextColor:[UIColor whiteColor]];
    
    notesTapGesture = [[UITapGestureRecognizer alloc] init];
    [[self view] addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer setDelegate:self];

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
    
    slideBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 460)];
    [slideBack addTarget:self action:@selector(slideLeft:) forControlEvents:UIControlEventTouchUpInside];
    [slideBack setBackgroundColor:[UIColor clearColor]];
    [slideBack setEnabled:NO];
    [self.view addSubview:slideBack];
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

#pragma mark - Setup custom controls

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


#pragma mark - View Actions and Gestures

////////////////////// REMOVE LATER ////////////////////////

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
        [TestFlight openFeedbackView];
}

///////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isEqual:tapAwayGesture])
    {
        if ((touch.view == myPopover) || (touch.view == chooseScalesButton) || (touch.view == chooseArpsButton) || (touch.view == choosePiecesButton))
            return NO;
        return YES;
    }
    return YES;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == panGestureRecognizer) && ([[self view] center].x > 170)) 
        return NO;
    if ((gestureRecognizer == panGestureRecognizer) || (gestureRecognizer != tapAwayGesture)) 
        return YES;
    else 
        return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{  
    static BOOL isVerticle;
    static CGFloat startingX;
    const CGFloat initiateX = 40.0;
    const CGFloat bounceX = 7.0;
    const CGFloat velocityThreshold = 300.0;
    const CGFloat viewWidth = [[self view] bounds].size.width;
    const CGFloat viewHeight = [[self view] bounds].size.height;
    const CGPoint theCenter = CGPointMake(viewWidth / 2.0, viewHeight / 2.0);
    const CGFloat rightX = theCenter.x + viewWidth - initiateX;
    CGFloat velocity = [gesture velocityInView:[self view]].x;
    CGPoint translation = [gesture translationInView:[self view]];
    CGFloat toX;
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        startingX = [[self view] center].x;
        if ((fabs(translation.y) + 1.0) >= fabs(translation.x) && (startingX == theCenter.x)) {
            isVerticle = YES;
            [statsTable setScrollEnabled:YES];
        }
        else {
            isVerticle = NO;
            [statsTable setScrollEnabled:NO];
        }
    }
    if (isVerticle) 
        return;
    toX = startingX + [gesture translationInView:[self view]].x;
    toX = MAX(toX, theCenter.x);
    toX = MIN(toX, rightX);
    [[self view] setCenter:CGPointMake(toX, theCenter.y)];
    BOOL didStartLeft = (startingX == theCenter.x);
    BOOL didInitiateMoveRight = (toX > theCenter.x + initiateX) || (velocity > velocityThreshold);
    BOOL didInitiateMoveLeft = (toX < rightX - initiateX) || (velocity < -velocityThreshold);
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        if ((didStartLeft && didInitiateMoveRight) || (!didStartLeft && !didInitiateMoveLeft)) {
            [UIView animateWithDuration:0.18 animations:^{
                [[self view] setCenter:CGPointMake(rightX + bounceX, theCenter.y)];
            } completion:^(BOOL finished){
                [statsTable setScrollEnabled:NO];
                [slideBack setEnabled:YES];
                [UIView animateWithDuration:0.08 animations:^{
                    [[self view] setCenter:CGPointMake(rightX, theCenter.y)];
                }];
            }];
        } 
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [[self view] setCenter:theCenter];
            } completion:^(BOOL finished){
                [statsTable setScrollEnabled:YES];
                [slideBack setEnabled:NO];
            }];
        }
    }
}

- (void)slideLeft:(id)sender
{
    const CGFloat viewWidth = [[self view] bounds].size.width;
    const CGFloat viewHeight = [[self view] bounds].size.height;
    const CGPoint theCenter = CGPointMake(viewWidth / 2.0, viewHeight / 2.0);
    [UIView animateWithDuration:0.25 animations:^{
        [[self view] setCenter:theCenter];
    } completion:^(BOOL finished){
        [statsTable setScrollEnabled:YES];
        [slideBack setEnabled:NO];
    }];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [notesView removeFromSuperview];
//    [panGestureRecognizer setEnabled:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    [panGestureRecognizer setEnabled:YES];
}

- (void)startMetronome:(id)sender {
    [metro startMetronomeWithTempo:[stepper tempo]];
    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StartMetronomeButton.png"]])
        [sender setImage:[UIImage imageNamed:@"StopButton.png"] forState:UIControlStateNormal];
    else if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"StopButton.png"]])
        [sender setImage:[UIImage imageNamed:@"StartMetronomeButton.png"] forState:UIControlStateNormal];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0 && currentPractice)
        return 27;
    return 42;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (2 + [[selectedSession pieceSession] count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSInteger numRowsInSection;
    
    if (currentPractice)
        numRowsInSection = [sectionInfo countofRowsToInsert] + 1;
    else
        numRowsInSection = [sectionInfo countofRowsToInsert];
    return (sectionInfo.open) ? numRowsInSection : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Session *s = [[SessionStore defaultStore] mySession];
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSString *sectionName = sectionInfo.title;
    sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 42) title:[sectionName capitalizedString] subTitle:@"" section:section delegate:self];
    NSString *time;
    if (currentPractice)
    {
        if (section ==  0)
            time = [NSString timeStringFromInt:[s scaleTime]];
        else if (section == 1)
            time = [NSString timeStringFromInt:[s arpeggioTime]];
        else
        {
            Piece *currentPiece = [[s pieceSession] objectAtIndex:(section - 2)];
            time = [NSString timeStringFromInt:[currentPiece pieceTime]];             
        }
    }
    else
    {
        if (section == 0)
            time = [NSString timeStringFromInt:[selectedSession scaleTime]];
        else if (section == 1)
            time = [NSString timeStringFromInt:[selectedSession arpeggioTime]];
        else
            time = [NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:(section - 2)] pieceTime]];
    }
    [sectionInfo.headerView setSubTitle:time];
    if (sectionInfo.open)
        [sectionInfo.headerView turnDownDisclosure:YES];
    else
        [sectionInfo.headerView turnDownDisclosure:NO];
    return sectionInfo.headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    LisztCell *cell;
    id entry;
    if (section < 2) {
        cell = (ScaleCell *)[tableView dequeueReusableCellWithIdentifier:@"ScaleCell"];
        if (cell == nil) 
            cell = [[ScaleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScaleCell"];
    }
    else {
        cell = (PieceCell *)[tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
        if (cell == nil) 
            cell = [[PieceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PieceCell"];
    }
    NSInteger dataIndex;
    if (row == 0 && currentPractice)
        return tCell;
    if (!currentPractice)
        dataIndex = row;
    else
        dataIndex = row - 1;
    if (section == 0)
        entry = [[selectedSession scaleSession] objectAtIndex:dataIndex];
    else if (section == 1)
        entry = [[selectedSession arpeggioSession] objectAtIndex:dataIndex];
    else {
        entry = [[selectedSession pieceSession] objectAtIndex:([indexPath section] - 2)];
    }
    [cell updateLabels:entry];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [statsTable setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    if (![indexPath row]) return NO;
    if (section < 2)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{  
    int section = [indexPath section];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSOrderedSet *removers;
        id cellToRemove;
        
        if (section == 0)
        {
            removers = [[[SessionStore defaultStore] mySession] scaleSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[[[SessionStore defaultStore] mySession] scaleSession] removeObject:cellToRemove];
            [[sectionInfoArray objectAtIndex:0] setCountofRowsToInsert:[[selectedSession scaleSession] count]];
        }
        else if (section == 1)
        {
            removers = [[[SessionStore defaultStore] mySession] arpeggioSession];
            cellToRemove = [removers objectAtIndex:[indexPath row] - 1];
            [[[[SessionStore defaultStore] mySession] arpeggioSession] removeObject:cellToRemove];
            [[sectionInfoArray objectAtIndex:1] setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([statsTable numberOfRowsInSection:section] == 1)
            [self closeSections];
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotesVC *notes = [[NotesVC alloc] initWithIndexPath:indexPath session:selectedSession];
    [self presentViewController:notes animated:YES completion:^{
    }];
}

#pragma mark - Handling Sections
- (void)closeSections
{
    for (int i = 0; i < [sectionInfoArray count]; i++)
    {
        SectionInfo *si = [sectionInfoArray objectAtIndex:i];
        if ([si open])
            [self sectionHeaderView:[si headerView] sectionClosed:i];
    }
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView tapped:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.open)
        [self sectionHeaderView:sectionHeaderView sectionOpened:section];
    else
        [self sectionHeaderView:sectionHeaderView sectionClosed:section];
}

- (void)setupTimerCellForSection:(NSInteger)section
{
    //    tCell = (TimerCell *) [statsTable dequeueReusableCellWithIdentifier:@"TimerCell"];
    tCell = [[[NSBundle mainBundle] loadNibNamed:@"TimerCell" owner:self options:nil] objectAtIndex:0];
    timerButton = [tCell timerButton];
    [timerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [timerButton addTarget:self action:@selector(timerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    
    [sectionHeaderView turnDownDisclosure:YES];
    NSInteger previousOpenSectionIndex = [self openSectionIndex];
    [self setOpenSectionIndex:section];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo setOpen:YES];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    if ([sectionInfo countofRowsToInsert] > 0 && currentPractice) {
        for (NSInteger i = 0; i <= [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [self setupTimerCellForSection:section];
        [timerButton setImage:[UIImage imageNamed:@"StartTimer.png"] forState:UIControlStateNormal];
    } else if ([sectionInfo countofRowsToInsert] > 0 && !currentPractice) {
        for (NSInteger i = 0; i < [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    } else {
        [sectionHeaderView turnDownDisclosure:NO];
        [sectionInfo setOpen:NO];
        [self setOpenSectionIndex:NSNotFound];
    }
    
    if (previousOpenSectionIndex != NSNotFound) {
        SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [previousOpenSection.headerView turnDownDisclosure:NO];
        if (currentPractice && isTiming)
            [self toggleTimer:previousOpenSectionIndex];
		
        [previousOpenSection setOpen:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        if (countOfRowsToDelete > 0 && currentPractice) {
            for (NSInteger i = 0; i <= countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else if (countOfRowsToDelete > 0 && !currentPractice) {
            for (NSInteger i = 0; i < countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else {
            [previousOpenSection.headerView turnDownDisclosure:NO];
            [previousOpenSection setOpen:NO];
        }
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
    // calling cellForRowAtIndexPath, is this bad?
    if (section > 1 && ![[statsTable visibleCells] containsObject: 
                         [statsTable cellForRowAtIndexPath:
                          [NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] -1 inSection:section]]])
        [statsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] - 1 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    if (section < 2)
        [statsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    [sectionHeaderView turnDownDisclosure:NO];
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo setOpen:NO];
    if (currentPractice && isTiming)
        [self toggleTimer:section];
    
    NSInteger countofRowsToDelete = [statsTable numberOfRowsInSection:section];
    if (countofRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (int i = 0; i < countofRowsToDelete; i++)
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [statsTable beginUpdates];
        [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
        [statsTable endUpdates];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)deleteSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    if (section > 1)
    {
        Piece *p = [[[[SessionStore defaultStore] mySession] pieceSession] objectAtIndex:section - 2];
        [[[[SessionStore defaultStore] mySession] pieceSession] removeObject:p];
        [sectionInfoArray removeObjectAtIndex:section];
        [statsTable deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setOpenSectionIndex:NSNotFound];
        NSString *timeString = [NSString timeStringFromInt:[self calculateTotalTime]];
        [totalTime setText:timeString];
        for (int i = section; i < [sectionInfoArray count]; i++)
        {
            NSInteger currentSection = [[[sectionInfoArray objectAtIndex:i] headerView] section];
            SectionHeaderView *currentHeader = [[sectionInfoArray objectAtIndex:i] headerView];
            [currentHeader setSection:(currentSection - 1)];
        }
    }
    [self setSwipedHeader:nil];
}

- (void)displayNotesViewForSection:(NSInteger)section headerView:(SectionHeaderView *)headerView
{
    CGRect frameOfExcludedArea = [self.view.superview convertRect:headerView.deleteView.frame fromView:headerView.deleteView.superview];
    CGPoint center = CGPointMake(frameOfExcludedArea.origin.x + (frameOfExcludedArea.size.width / 2),
                                 frameOfExcludedArea.origin.y + (frameOfExcludedArea.size.height / 2));
    [notesTapGesture addTarget:self action:@selector(getRidOfNotes:)];
    [notesTapGesture setEnabled:YES];
    [self.view addGestureRecognizer:notesTapGesture];
    notesView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    [notesView setDelegate:self];
    [notesView setCenter:CGPointMake(center.x, center.y - 75)];
    Session *mySession = [[SessionStore defaultStore] mySession];
    NSString *notesViewText;
    switch (swipedHeader.section) {
        case 0:
            notesViewText = [mySession scaleNotes];
            break;
        case 1:
            notesViewText = [mySession arpeggioNotes];
        default:
            notesViewText = [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] pieceNotes];
            break;
    }
    [notesView setText:notesViewText];
    [self.view addSubview:notesView];
}
- (void)getRidOfNotes:(id)sender
{
    [notesView removeFromSuperview];
    [notesTapGesture setEnabled:NO];
    Session *mySession = [[SessionStore defaultStore] mySession];
    switch (swipedHeader.section) {
        case 0:
            [mySession setScaleNotes:[notesView text]];
            break;
        case 1:
            [mySession setArpeggioNotes:[notesView text]];
        default:
            [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] setPieceNotes:[notesView text]];
            break;
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        Session *mySession = [[SessionStore defaultStore] mySession];
        [textView resignFirstResponder];
        [textView removeFromSuperview];
        [notesTapGesture setEnabled:NO];
        switch (swipedHeader.section) {
            case 0:
                [mySession setScaleNotes:[textView text]];
                break;
            case 1:
                [mySession setArpeggioNotes:[textView text]];
            default:
                [[[mySession pieceSession] objectAtIndex:swipedHeader.section - 2] setPieceNotes:[textView text]];
                break;
        }
        return FALSE;
    }
    return TRUE;
}

- (void)sectionSwiped:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
{
    self.swipedHeader = sectionHeaderView;
}

- (UIView *)hitWithPoint:(CGPoint)point
{
    if (swipedHeader)
    {
        if ([notesView isDescendantOfView:self.view])
            return nil;
        CGRect frameOfExcludedArea = [self.view.superview convertRect:swipedHeader.deleteView.frame fromView:swipedHeader.deleteView.superview];
        if ((point.y > frameOfExcludedArea.origin.y-20) && (point.y < frameOfExcludedArea.origin.y-20 + frameOfExcludedArea.size.height))
        {
            if(point.x > (self.view.frame.size.width / 2))
                return swipedHeader.deleteButton;
            else
                return swipedHeader.notesButton;
        }
        else if (CGRectContainsPoint([notesView frame], point))
        {
            return notesView;
        }
        else if (CGRectContainsPoint([statsTable frame], point))
        {
            [swipedHeader cancelDelete:nil];
            [self setSwipedHeader:nil];
            return statsTable;
        }
        else 
        {
            [swipedHeader cancelDelete:nil];
            [self setSwipedHeader:nil];
            return nil;
        }
    }
    return nil;
}

//- (void)moveSection:(NSInteger)section headerView:(SectionHeaderView *)sectionHeaderView
//{
//    if (section > 1)
//    {
//        sectionMover = [[CustomSectionMove alloc] initWithFrame:[statsTable frame]
//                                               numberOfSections:[statsTable numberOfSections]
//                                                heightOfSection:[statsTable sectionHeaderHeight]];
//        [sectionMover setOldSection:section];
//        [sectionMover setDelegate:self];
//        [self.view addSubview:sectionMover];
//    }
//}

- (void)sectionMoveLocationSelected:(NSInteger)section
{
//    if (section > 1)
//    {
//        [[[sectionInfoArray objectAtIndex:[sectionMover oldSection]] headerView] setSection:section];
//        NSInteger largerSection = MAX([sectionMover oldSection], section);
//        NSInteger smallerSection = MIN([sectionMover oldSection], section);
//        for (int i = smallerSection; i < largerSection; i++)
//        {
//            [[[sectionInfoArray objectAtIndex:i] headerView] setSection:i + 1];
//            
//        }
//        SectionInfo *objectToMove = [sectionInfoArray objectAtIndex:[sectionMover oldSection]];
//        [sectionInfoArray removeObject:objectToMove];
//        [sectionInfoArray insertObject:objectToMove atIndex:section];
//        [sectionMover removeFromSuperview];
//        [statsTable beginUpdates];
//        [statsTable moveSection:[sectionMover oldSection] toSection:section];
//        [statsTable endUpdates];
//    }
}


@end
