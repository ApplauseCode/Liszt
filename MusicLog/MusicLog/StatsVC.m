//
//  StatsVC.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "StatsVC.h"
#import "ScalePickerVC.h"
#import "PiecesPickerVC.h"
#import "SessionStore.h"
#import "Session.h"
#import "NSString+Number.h"
#import "LisztCell.h"
#import "ScaleCell.h"
#import "PieceCell.h"
#import "Scale.h"
#import "Piece.h"
#import "SectionHeaderView.h"
#import "SectionInfo.h"
#import "CustomStepper.h"
#import "TimerCell.h"
#import "UIColor+YellowTextColor.h"
#import "BlockAlertView.h"
#import "ContainerViewController.h"
#import "HistoryViewController.h"
#import "NotesPickerVC.h"
#import "Other.h"
#import "OtherVC.h"
#import "OtherCell.h"
#import "PopupCell.h"

#pragma mark - Private Interface

@interface StatsVC ()
@property (nonatomic, strong) id theObserver;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *metroPanGestureRecognizer;
@property (nonatomic, strong) UIButton *slideBack;
@property (nonatomic, strong) IBOutlet UIImageView *metronomeTicker;
@property (strong, nonatomic) IBOutlet UIView *woodenMetronome;
@property (strong, nonatomic) NSTimer *metronomeScreenTimer;
@property (strong, nonatomic) NSTimer *stopWatchTimer;
@property (nonatomic, strong) NSTimer *idleScreenTimer;
@property (assign, nonatomic) BOOL isUpdatingTime; 
@property (nonatomic, strong) id tickingItem;
@property (nonatomic, strong) UILabel *nothingInTable;

- (void)handlePan:(UIPanGestureRecognizer *)gesture;
- (void)handleMetroPan:(UIPanGestureRecognizer *)recognizer;
- (void)setupSectionInfoArray;
- (void)stopWatchTick:(NSTimer *)timer;

@end

@implementation StatsVC
@synthesize nothingInTable;
@synthesize idleScreenTimer;
@synthesize tickingItem;
@synthesize isUpdatingTime;
@synthesize notesCell;
@synthesize metronomeScreenTimer;
@synthesize screenBrightness;
@synthesize dimScreenTimer;
@synthesize metronomeGrabber;
@synthesize metronomeTicker;
@synthesize woodenMetronome;
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
@synthesize tapAwayGesture;
@synthesize greyMask;
@synthesize sectionInfoArray;
@synthesize openSectionIndex;
@synthesize metro;
@synthesize tCell;
@synthesize shouldDisplayTime;
@synthesize theObserver;
@synthesize isTiming;
@synthesize notesView;
@synthesize notesTapGesture;
@synthesize panGestureRecognizer;
@synthesize metroPanGestureRecognizer;
@synthesize slideBack;
@synthesize tempoChooser;
@synthesize stopWatchTimer;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [self setWoodenMetronome:nil];
    [self setMetronomeGrabber:nil];
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
- (BOOL)canBecomeFirstResponder { return YES;}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [idleScreenTimer invalidate];
    idleScreenTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(idleScreenTimerFire:) userInfo:nil repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(stopWatchTick:) userInfo:nil repeats:YES];
    [runLoop addTimer:stopWatchTimer forMode:NSRunLoopCommonModes];
    [runLoop addTimer:stopWatchTimer forMode:UITrackingRunLoopMode];
    
    UIScreen *screen = [UIScreen mainScreen];
    [self setScreenBrightness:[screen brightness]];
    [self setDimScreenTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(dimTimerFire:) userInfo:nil repeats:NO]];
    [(StatsView *) self.view setDelegate:self];
    isTiming = NO;
    [selSessionDisplay setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:22]];
    [selSessionDisplay setTextColor:[UIColor yellowTextColor]];
    
    notesTapGesture = [[UITapGestureRecognizer alloc] init];
    [[self view] addGestureRecognizer:panGestureRecognizer];
    [panGestureRecognizer setDelegate:self];

    [statsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [statsTable setTableFooterView:footer];
    
    totalTime = [[UILabel alloc] initWithFrame:CGRectMake(239, 50, 100, 36)];
    [totalTime setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [totalTime setTextColor:[UIColor yellowTextColor]];
    [totalTime setBackgroundColor:[UIColor clearColor]];
    NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
    [totalTime setText:timeString];
    [self.view addSubview:totalTime];
    
    UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:12];
    [tempoNameLabel setFont:caslon];
    [tempoNameLabel setText:@"METRONOME:"];
    [tempoNameLabel setTextColor:[UIColor yellowTextColor]];
    [self makeMenu];
    [self makeMetronome];

    slideBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 460)];
    [slideBack addTarget:self action:@selector(slideLeft:) forControlEvents:UIControlEventTouchUpInside];
    [slideBack setBackgroundColor:[UIColor clearColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    [self closeSections];
    [self stopAllTimers];
}

- (void)setupSectionInfoArray
{
    [sectionInfoArray removeAllObjects];
    SectionInfo *sectionZero = [[SectionInfo alloc] init];
    [sectionZero setOpen:NO];
    [sectionZero setTitle:@"scales"];
    [sectionZero setCountofRowsToInsert:[[selectedSession scaleSession] count]];
    SectionInfo *sectionOne = [[SectionInfo alloc] init];
    [sectionOne setOpen:NO];
    [sectionOne setTitle:@"arpeggios"];
    [sectionOne setCountofRowsToInsert:[[selectedSession arpeggioSession] count]];
    sectionInfoArray = [NSMutableArray arrayWithObjects:sectionZero, sectionOne, nil];
    for (int i = 0; i < [[selectedSession pieceSession] count]; i++)
    {
        SectionInfo *itemInfo = [[SectionInfo alloc] init];
        [itemInfo setTitle:[[[selectedSession pieceSession] objectAtIndex:i] title]];
        [itemInfo setCountofRowsToInsert:1];
        if ([[[selectedSession pieceSession] objectAtIndex:i] isKindOfClass:[Other class]])
            [itemInfo setIsOther:YES];
        [sectionInfoArray addObject:itemInfo];
    }
    if ([selectedSession sessionNotes])
    {
        SectionInfo *notes = [[SectionInfo alloc] init];
        [notes setTitle:@"Notes"];
        [notes setCountofRowsToInsert:1];
        [notes setIsNotes:YES];
        [notes setHeaderView:[[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, statsTable.bounds.size.width, 42)
                                                                title:notes.title subTitle:nil section:[sectionInfoArray count] delegate:self]];
        [sectionInfoArray addObject:notes];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self startTimers];
    [self setupSectionInfoArray];
    [statsTable reloadData];
    [self hideMenu:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isFirstLaunch = [NSNumber numberWithBool:YES];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:isFirstLaunch, @"FirstLaunch", nil];
    [defaults registerDefaults:appDefaults];
    if ([[defaults objectForKey:@"FirstLaunch"] boolValue]) 
    {
            nothingInTable = [[UILabel alloc] initWithFrame:CGRectMake(50, 125, 230, 100)];
            [nothingInTable setBackgroundColor:[UIColor clearColor]];
            [nothingInTable setNumberOfLines:3];
            [nothingInTable setTextAlignment:UITextAlignmentCenter];
            [nothingInTable setFont:[UIFont fontWithName:@"ACaslonPro-Italic" size:22]];
            [nothingInTable setText:@"Welcome to Liszt! Press the plus button to add items to your practice."];
            [self.statsTable addSubview:nothingInTable];
    }
}

# pragma mark - Popover Menu

- (void) makeMenu {
    myPopover = [[PopupVC alloc] initWithFrame:CGRectMake(195, 47, 116, 199)];
    [myPopover setDelegate:self];
    [myPopover.view setAlpha:0];
    
    NSArray *cellTitles = [NSArray arrayWithObjects:@"Scales", @"Arpeggios", @"Pieces", @"Notes", @"Other", nil];
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:[cellTitles count]];
    for (NSString *title in cellTitles)
    {
        PopupCell *cell = [[PopupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setButtonTitle:title];
        [cell setTag:[cellTitles indexOfObject:title]];
        [cells addObject:cell];
        
    }
    [myPopover setStaticCells:cells];
    tapAwayGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu:)];
    [tapAwayGesture setDelegate:self];
    [self.view addGestureRecognizer:tapAwayGesture];
    [tapAwayGesture setEnabled:NO];
    greyMask = [[UIView alloc] initWithFrame:[self.view frame]];
    [greyMask setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
    [greyMask setAlpha:0];
}

- (void)showMenu:(id)sender
{
        
    [self.view addSubview:greyMask];
    [self.view addSubview:myPopover.view];
    [UIView animateWithDuration:0.2 animations:^{
        [greyMask setAlpha:0.2];
        [myPopover.view setAlpha:1.0];
    }];
    [tapAwayGesture setEnabled:YES];
    for (SectionInfo *info in sectionInfoArray)
        [[[info headerView] tapGesture] setEnabled:NO];
}

- (void)hideMenu:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        [myPopover.view setAlpha:0];
        [greyMask setAlpha:0];
    } completion:^(BOOL finished) {
        [myPopover.view removeFromSuperview];
        [greyMask removeFromSuperview];
    }];
    [tapAwayGesture setEnabled:NO];
    for (SectionInfo *info in sectionInfoArray)
        [[[info headerView] tapGesture] setEnabled:YES];
}

#pragma mark - Metronome

- (void) makeMetronome {
    tempoChooser = [[ACchooser alloc]initWithFrame:CGRectMake(87, 26, 150, 58)];
    UIImageView *chooserOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScrollerShadingNoArrow.png"]];
    [chooserOverlay setFrame:CGRectMake(80, 25, 164, 58)];
    NSMutableArray *tempos = [[NSMutableArray alloc] initWithCapacity:290];
    for (int i = 30; i <= 320; i++)
        [tempos addObject:[NSString stringWithInt:i]];
    [tempoChooser setDataArray:tempos];
    [tempoChooser setDelegate:self];
    [tempoChooser setCellColor:[UIColor clearColor]];
    [tempoChooser setSelectedBackgroundColor:[UIColor clearColor]];
    [tempoChooser setCellFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:18]];
    [metronomeView addSubview:tempoChooser.view];
    [metronomeView addSubview:chooserOverlay];
    [tempoChooser setSelectedCellIndex:90];
    [stepper setDelegate:self];
    metroPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMetroPan:)];
    [metronomeGrabber setUserInteractionEnabled:YES];
    [metronomeGrabber addGestureRecognizer:metroPanGestureRecognizer];
    openSectionIndex = NSNotFound;
    metro = [[Metronome alloc] init];
    [metro setDelegate:self];
}

- (void)startMetronome:(id)sender {
    [metro startMetronomeWithTempo:[tempoChooser selectedCellIndex] + 30];
    if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"metronomePlay.png"]])
        [sender setImage:[UIImage imageNamed:@"metronomePause.png"] forState:UIControlStateNormal];
    else if ([[sender imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"metronomePause.png"]])
        [sender setImage:[UIImage imageNamed:@"metronomePlay.png"] forState:UIControlStateNormal];
}
- (void)metronomeWillStartWithInterval:(CGFloat)interval
{
    [UIView animateWithDuration:interval animations:^{
        [metronomeTicker setTransform:CGAffineTransformMakeRotation(M_PI/6)];
    }];
}

- (void)stopAnimationWithInterval:(CGFloat)interval
{
    [UIView animateWithDuration:interval delay:0 options:UIViewAnimationCurveEaseIn animations:^{
        [metronomeTicker setTransform:CGAffineTransformMakeRotation(0)]; 
    } completion:^(BOOL finished) {
    }];
}

- (void)metronomeDidStartWithInterval:(CGFloat)interval
{
    if (CGAffineTransformEqualToTransform(metronomeTicker.transform, CGAffineTransformMakeRotation(M_PI/6)))
    {
        [UIView animateWithDuration:interval delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            [metronomeTicker setTransform:CGAffineTransformMakeRotation(-M_PI/6)]; 
        } completion:^(BOOL finished) {
            if (![metro isPlaying])
                [self stopAnimationWithInterval:interval];
        }];
    }
    else
    {
        [UIView animateWithDuration:interval delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            [metronomeTicker setTransform:CGAffineTransformMakeRotation(M_PI/6)]; 
        } completion:^(BOOL finished) {
            if (![metro isPlaying])
                [self stopAnimationWithInterval:interval];
        }];
    }
}

- (void)chooserDidSelectCell:(ACchooser *)chooser
{
    [metro changeTempoWithTempo:[chooser selectedCellIndex] + 30];
}
- (void)handleMetroPan:(UIPanGestureRecognizer *)recognizer
{
#define UP_CENTER_Y 417  
#define HEIGHT_OF_EXTRA_GRAB_SPACE 11
    static CGFloat startingY;
    const CGFloat metroWidth = [[self metronomeView] bounds].size.width;
    const CGFloat metroHeight = [[self view] bounds].size.height - [metronomeView bounds].size.height + [metronomeGrabber bounds].size.height - HEIGHT_OF_EXTRA_GRAB_SPACE;
    const CGPoint theCenter = CGPointMake(metroWidth / 2.0, metroHeight + [metronomeView bounds].size.height / 2.0);
    CGPoint translation = [recognizer translationInView:[self view]];
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        startingY = [metronomeView center].y;
    }
    CGFloat toY = startingY + translation.y;
    // this calculation is a kludge but it works, will figure out why later;
    toY = MAX(toY, theCenter.y - [metronomeGrabber bounds].size.height + HEIGHT_OF_EXTRA_GRAB_SPACE);
    toY = MIN(toY, self.view.frame.size.height + 22);
    //toY = MIN(toY, theCenter.y + [metronomeView bounds].size.height / 2.0 - 3);
    [metronomeView setCenter:CGPointMake(theCenter.x, toY)];
    BOOL didStartUp = startingY == UP_CENTER_Y;
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        if (didStartUp && translation.y > 0) {
#define TOPWOODCENTER 416
#define BOTTOMWOODCENTER 506
            [UIView animateWithDuration:0.125 animations:^{
                [metronomeView setCenter:CGPointMake(theCenter.x, -2 + theCenter.y + [metronomeView bounds].size.height / 2.0)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    if (![metro isPlaying])
                        [woodenMetronome setCenter:CGPointMake(woodenMetronome.center.x, BOTTOMWOODCENTER)];
                }];
            }];
        } else if (!didStartUp && translation.y < 0) {
            [UIView animateWithDuration:0.125 animations:^{
                [metronomeView setCenter:CGPointMake(theCenter.x, UP_CENTER_Y)];
            } completion:^(BOOL finished) {
                [self setMetronomeScreenTimer:[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(metronomeTimerFire:) userInfo:nil repeats:NO]];
                [UIView animateWithDuration:0.5 animations:^{
                    [woodenMetronome setCenter:CGPointMake(woodenMetronome.center.x,TOPWOODCENTER)];
                }];
            }];

        }
        
    }
}

- (void)metronomeTimerFire:(NSTimer *)theTimer
{
    CGFloat metroHeight = [[self view] bounds].size.height - [metronomeView bounds].size.height + [metronomeGrabber bounds].size.height - HEIGHT_OF_EXTRA_GRAB_SPACE;
    CGFloat metroWidth = [[self metronomeView] bounds].size.width;
    CGPoint theCenter = CGPointMake(metroWidth / 2.0, metroHeight + [metronomeView bounds].size.height / 2.0);
    [UIView animateWithDuration:0.25 animations:^{
        [metronomeView setCenter:CGPointMake(theCenter.x, -2 + theCenter.y + [metronomeView bounds].size.height / 2.0)];
        if (![metro isPlaying])
            [woodenMetronome setCenter:CGPointMake(woodenMetronome.center.x, BOTTOMWOODCENTER)];
    }];
}

- (void)valueChanged
{
    [metro changeTempoWithTempo:[stepper tempo]];
}

#pragma mark - Custom controls, actions & gestures

////////////////////// REMOVE LATER ////////////////////////

//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventSubtypeMotionShake)
//        [TestFlight openFeedbackView];
//}
///////////////////////////////////////////////////////////
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isEqual:tapAwayGesture])
    {
        if (CGRectContainsPoint([myPopover.view frame], [touch locationInView:self.view]))
            return NO;
    }
    if ([gestureRecognizer isEqual:panGestureRecognizer])
        if (CGRectContainsPoint(tempoChooser.view.frame, [touch locationInView:self.metronomeView]))
            return NO;
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

- (void)handlePan:(UIPanGestureRecognizer *)gR
{  
    static BOOL isVertical;
    static CGFloat startingX;
    const CGFloat initiateX = 45.0;
    const CGFloat bounceX = 10.0;
    const CGFloat velocityThreshold = 300.0;
    const CGFloat viewWidth = [[self view] bounds].size.width;
    const CGFloat viewHeight = [[self view] bounds].size.height;
    const CGPoint theCenter = CGPointMake(viewWidth / 2.0, viewHeight / 2.0);
    const CGFloat rightX = theCenter.x + viewWidth - initiateX;
    
    CGFloat velocity = [gR velocityInView:[self view]].x;
    CGPoint translation = [gR translationInView:[self view]];
    
    if ([gR state] == UIGestureRecognizerStateBegan) {
        ContainerViewController *cvc = (ContainerViewController *)[self parentViewController];
        HistoryViewController *hvc = [[cvc viewControllers] objectAtIndex:1];
        [hvc reloadFirstCell];
        startingX = [[self view] center].x;
        if ((fabs(translation.y) + 1.0) >= fabs(translation.x) && (startingX == theCenter.x)) {
            [statsTable setScrollEnabled:YES];
            isVertical = YES; 
        }
        else {
            [statsTable setScrollEnabled:NO];
            isVertical = NO;
        }
    }
    if (isVertical) return;
    
    CGFloat toX;
    toX = startingX + translation.x;
    toX = MAX(toX, theCenter.x);
    toX = MIN(toX, rightX);
    [[self view] setCenter:CGPointMake(toX, theCenter.y)];
    
    BOOL didStartCenter = (startingX == theCenter.x);
    BOOL didInitiateMoveRight = (toX > theCenter.x + initiateX) || (velocity > velocityThreshold);
    BOOL didInitiateMoveLeft = (toX < rightX - initiateX) || (velocity < -velocityThreshold);
    BOOL shouldMoveRight = (didStartCenter && didInitiateMoveRight) || (!didStartCenter && !didInitiateMoveLeft);
    
    if ([gR state] == UIGestureRecognizerStateEnded) {
        if (shouldMoveRight) {
            [UIView animateWithDuration:0.18 animations:^{
                [[self view] setCenter:CGPointMake(rightX + bounceX, theCenter.y)];
            } completion:^(BOOL finished){
                [statsTable setScrollEnabled:NO];
                [self.view addSubview:slideBack];
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
                [slideBack removeFromSuperview];
            }];
        }
    }
}

- (IBAction)slideRight:(id)sender 
{
    const CGFloat initiateX = 45;
    const CGFloat viewWidth = [[self view] bounds].size.width;
    const CGFloat viewHeight = [[self view] bounds].size.height;
    const CGPoint theCenter = CGPointMake(viewWidth / 2.0, viewHeight / 2.0);
    const CGFloat rightX = theCenter.x + viewWidth - initiateX;
    const CGFloat bounceX = 10.0;
    [UIView animateWithDuration:0.18 animations:^{
        [[self view] setCenter:CGPointMake(rightX + bounceX, theCenter.y)];
    } completion:^(BOOL finished){
        [statsTable setScrollEnabled:NO];
        [self.view addSubview:slideBack];
        [UIView animateWithDuration:0.08 animations:^{
            [[self view] setCenter:CGPointMake(rightX, theCenter.y)];
        }];
    }];
}

- (void)slideLeft:(id)sender
{
    const CGFloat viewWidth = [[self view] bounds].size.width;
    const CGFloat viewHeight = [[self view] bounds].size.height;
    const CGPoint theCenter = CGPointMake(viewWidth / 2.0, viewHeight / 2.0);
    [UIView animateWithDuration:0.375 animations:^{
        [[self view] setCenter:theCenter];
    } completion:^(BOOL finished){
        [statsTable setScrollEnabled:YES];
        [slideBack removeFromSuperview];
    }];
}

- (void)cellSelectedAtIndex:(NSInteger)index
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isFirstLaunch = [NSNumber numberWithBool:YES];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:isFirstLaunch, @"FirstLaunch", nil];
    [defaults registerDefaults:appDefaults];
    if ([[defaults objectForKey:@"FirstLaunch"] boolValue]) 
    {
        [defaults setBool:NO forKey:@"FirstLaunch"];
        [defaults synchronize];
        [nothingInTable removeFromSuperview];
    }
    id vc;
    switch (index) {
        case 0:
            vc = [[ScalePickerVC alloc] initWithIndex:0 editPage:NO];
            break;
        case 1:
            vc = [[ScalePickerVC alloc] initWithIndex:1 editPage:NO];
            break;
        case 2:
            vc = [[PiecesPickerVC alloc] initWithEditMode:NO];
            break;
        case 3:
            if (![selectedSession sessionNotes])
                vc = [[NotesPickerVC alloc] initWithEditMode:NO];
            break;
        case 4:
            vc = [[OtherVC alloc] initWithEditMode:NO];
            break;
    }  
    if (vc)
        [self presentModalViewController:vc animated:YES];

}

#pragma mark - Timers
- (void)idleScreenTimerFire:(NSTimer *)timer
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)setMetronomeScreenTimer:(NSTimer *)aTimer
{
    if (aTimer != metronomeScreenTimer) {
        [metronomeScreenTimer invalidate];
        metronomeScreenTimer = aTimer;
    }
}

- (void)setDimScreenTimer:(NSTimer *)aTimer
{
    if (aTimer != dimScreenTimer) {
        [dimScreenTimer invalidate];
        dimScreenTimer = aTimer;
    }
}

- (void)timerButtonPressed:(id)sender
{
    if (!tickingItem)
    {
        self.tickingItem = [[SessionStore defaultStore] mySession];
        switch (openSectionIndex) {
            case 0:
                [self.tickingItem resetStartTime:0];
                break;
            case 1:
                [self.tickingItem resetStartTime:1];
                break;
            default:
                self.tickingItem = [[self.tickingItem pieceSession] objectAtIndex:(openSectionIndex - 2)];
                [self.tickingItem resetStartTime];
                break;
        }
        [self setIsUpdatingTime:YES];
        [sender setImage:[UIImage imageNamed:@"stopTimerLarge.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.tickingItem = nil;
        [self setIsUpdatingTime:NO];
        [sender setImage:[UIImage imageNamed:@"startTimerLarge.png"] forState:UIControlStateNormal];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        dispatch_async(queue, ^{
            [[SessionStore defaultStore] saveChanges];
        });
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if(acceleration.y > 0.09 || acceleration.x > 0.09 || acceleration.z > 0.09)
    {
        UIScreen *mainScreen = [UIScreen mainScreen];
        if ([mainScreen brightness] != [self screenBrightness])
            mainScreen.brightness = [self screenBrightness]; 
        
        [self setDimScreenTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(dimTimerFire:) userInfo:nil repeats:NO]];
            
    } 
}

- (void)dimTimerFire:(NSTimer*)theTimer;
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    mainScreen.brightness = 1.0/7.0;

}

- (UIView *)hitWithPoint:(CGPoint)point
{
    // check metronome screen
    if (CGRectContainsPoint(metronomeView.frame, point))
    {
        [self setMetronomeScreenTimer:[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(metronomeTimerFire:) userInfo:nil repeats:NO]];
    }
    
    // check screens brightness
    UIScreen *mainScreen = [UIScreen mainScreen];
    if ([mainScreen brightness] != [self screenBrightness])
        mainScreen.brightness = [self screenBrightness]; 
    [self setDimScreenTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(dimTimerFire:) userInfo:nil repeats:NO]];
    
    return nil;
}

- (void)stopWatchTick:(NSTimer *)timer
{
    if (self.tickingItem)
    {
        if (openSectionIndex < 2)
            [self.tickingItem updateElapsedTime:[NSDate date] forIndex:openSectionIndex];
        else
        {
            [self.tickingItem updateElapsedTime:[NSDate date]];
        }
        NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
        [totalTime setText:timeString];
        [statsTable reloadData];
    }
}

- (void)stopAllTimers
{
    [self.idleScreenTimer invalidate];
    [stopWatchTimer invalidate];
    
    [timerButton setImage:[UIImage imageNamed:@"startTimerLarge.png"] forState:UIControlStateNormal];
    [self setTickingItem:nil];
    [dimScreenTimer invalidate];
    [metronomeScreenTimer invalidate];

}

- (void)startTimers
{
    [self.stopWatchTimer invalidate];
    [self setDimScreenTimer:[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(dimTimerFire:) userInfo:nil repeats:NO]];
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(stopWatchTick:) userInfo:nil repeats:YES];
    
    [dimScreenTimer invalidate];
    
    
    [idleScreenTimer invalidate];
    [self idleScreenTimerFire:nil];
    idleScreenTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(idleScreenTimerFire:) userInfo:nil repeats:YES];

}

#pragma mark - Date Selection

- (void)blockAlertView:(BOOL)isYes
{
    SessionStore *store = [SessionStore defaultStore];
    [store startNewSession:isYes];
    [self setSelectedSession:[store mySession]];
    [self setupSectionInfoArray];
    [statsTable reloadData];
    NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
    [totalTime setText:timeString];
}

- (void)showStatsAtIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view setCenter:CGPointMake(self.view.center.x + 65, self.view.center.y)];
                     } completion:^(BOOL finished) {
                         NSArray *s = [[SessionStore defaultStore] sessions];
                         if (index == [s count])
                             [self dateChangedWithDate:[NSDate date]];
                         else
                             [self dateChangedWithDate:[[s objectAtIndex:index] date]];
                         [self slideLeft:nil];
                     }];
}

- (void)dateChangedWithDate:(NSDate *)date
{
    [self closeSections];
    
    Session *filteredSession = [[SessionStore defaultStore] sessionForDate:date];
    
    if (filteredSession == [[SessionStore defaultStore] mySession])
    {
        [selSessionDisplay setText:@"Current Practice"];
        selectedSession = [[SessionStore defaultStore] mySession];
        currentPractice = YES;
    }
    else
    {
        selectedSession = filteredSession;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd, yyyy"];
        [selSessionDisplay setText:[dateFormat stringFromDate:[selectedSession date]]];
        currentPractice = NO;
    }
    [self setupSectionInfoArray];
    [statsTable reloadData];
    NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
    [totalTime setText:timeString];    
}

#pragma mark - ScrollView & TableView

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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[sectionInfoArray objectAtIndex:[indexPath section]] isNotes])
        return 133 ;
    else if ([indexPath row] == 0 && currentPractice)
        return 46;
    if ([indexPath section] < 2)
        return 49;
    else if ([[[selectedSession pieceSession] objectAtIndex:[indexPath section] - 2] isKindOfClass:[Other class]]) {
        return 186;
    }
    return 49;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 42;
    switch (section) {
        case 0:
            if (![[selectedSession scaleSession] count])
                height = 0;
            break;
        case 1:
            if (![[selectedSession arpeggioSession] count])
                height = 0;
            break;
        default:
            break;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionInfoArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    NSInteger numRowsInSection;
    

    if (currentPractice && ![sectionInfo isNotes])
        numRowsInSection = [sectionInfo countofRowsToInsert] + 1;
    else
        numRowsInSection = [sectionInfo countofRowsToInsert];
    return (sectionInfo.open) ? numRowsInSection : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Session *s = [[SessionStore defaultStore] mySession];
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (![sectionInfo isNotes])
    {
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
                if (![[sectionInfoArray objectAtIndex:section] isOther])
                {
                    Piece *currentPiece = [[s pieceSession] objectAtIndex:(section - 2)];
                    time = [NSString timeStringFromInt:[currentPiece pieceTime]];  
                }
                else {
                    Other *currentOther = [[s pieceSession] objectAtIndex:(section - 2)];
                    time = [NSString timeStringFromInt:[currentOther otherTime]];
                }
            }
        }
        else
        {
            if (section == 0)
                time = [NSString timeStringFromInt:[selectedSession scaleTime]];
            else if (section == 1)
                time = [NSString timeStringFromInt:[selectedSession arpeggioTime]];
            else /* FIX THIS */
            {
                if (![[sectionInfoArray objectAtIndex:section] isOther])
                    time = [NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:(section - 2)] pieceTime]];
                else
                    time = [NSString timeStringFromInt:[[[selectedSession pieceSession] objectAtIndex:(section - 2)] otherTime]];
            }
        }
        [sectionInfo.headerView setSubTitle:time];
    }
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
    if (section == [statsTable numberOfSections] - 1 && [[sectionInfoArray objectAtIndex:[indexPath section]] isNotes])
    {
        notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
        notesCell.textView.text = [selectedSession sessionNotes];
        notesCell.root = self;
        notesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (currentPractice)
            [notesCell setTextViewCanEdit:YES];
        else
            [notesCell setTextViewCanEdit:NO];
        return notesCell;
    }
    if (section < 2) {
        cell = (ScaleCell *)[tableView dequeueReusableCellWithIdentifier:@"ScaleCell"];
        if (cell == nil) 
            cell = [[ScaleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScaleCell"];
    }
    else {
        if ([[[selectedSession pieceSession] objectAtIndex:section - 2] isKindOfClass:[Piece class]])
        {
            cell = (PieceCell *)[tableView dequeueReusableCellWithIdentifier:@"PieceCell"];
            if (cell == nil) 
                cell = [[PieceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PieceCell"];
        }
        else {
            cell = (OtherCell *)[tableView dequeueReusableCellWithIdentifier:@"OtherCell"];
            if (cell == nil)
                cell = [[OtherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OtherCell"];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSInteger dataIndex;
    if (row == 0 && currentPractice)
        return tCell;
    if (!currentPractice)
    {
        dataIndex = row;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
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
    if (section < 2 && currentPractice && [indexPath row])
        return YES;
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
        {
            [self closeSections];
            if (section == 0)
                [[[SessionStore defaultStore] mySession] setScaleTime:0];
            else
                [[[SessionStore defaultStore] mySession] setArpeggioTime:0];
        }
    }   
    NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
    [totalTime setText:timeString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!currentPractice)
        return;
    [self closeSections];
    NSInteger section = [indexPath section];
    id editVC;
    switch (section) {
        case 0:
            editVC = [[ScalePickerVC alloc] initWithIndex:0 editPage:YES];
            break;
        case 1:
            editVC = [[ScalePickerVC alloc] initWithIndex:1 editPage:YES];
            break;
        default:
            if (![[sectionInfoArray objectAtIndex:section] isOther])
                editVC = [[PiecesPickerVC alloc] initWithEditMode:YES];
            else
                editVC = [[OtherVC alloc] initWithEditMode:YES];
            break;
    }
    [editVC setEditItemPath:indexPath];
    [editVC setSelectedSession:selectedSession];
    [self presentModalViewController:editVC animated:YES];
}

#pragma mark - Handling Sections
- (void)closeSections
{
    for (int i = 0; i < [sectionInfoArray count]; i++)
    {
        SectionInfo *si = [sectionInfoArray objectAtIndex:i];
        if ([si open])
            [self sectionClosed:i];
    }
}

- (void)sectionTapped:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.open)
        [self sectionOpened:section];
    else
        [self sectionClosed:section];
}

- (void)setupTimerCellForSection:(NSInteger)section
{
    tCell = [[[NSBundle mainBundle] loadNibNamed:@"TimerCell" owner:self options:nil] objectAtIndex:0];
    timerButton = [tCell timerButton];
    [timerButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    [timerButton addTarget:self action:@selector(timerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)sectionOpened:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [[sectionInfo headerView] turnDownDisclosure:YES];
    NSInteger previousOpenSectionIndex = [self openSectionIndex];
    [self setOpenSectionIndex:section];
    [sectionInfo setOpen:YES];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    if ([sectionInfo isNotes])
    {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:0 inSection:section]];
    }
    else if ([sectionInfo countofRowsToInsert] > 0 && currentPractice) {
        for (NSInteger i = 0; i <= [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        [self setupTimerCellForSection:section];
    } else if ([sectionInfo countofRowsToInsert] > 0 && !currentPractice) {
        for (NSInteger i = 0; i < [sectionInfo countofRowsToInsert]; i++)
            [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    } 
    
    if (previousOpenSectionIndex != NSNotFound) {
        SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        [previousOpenSection.headerView turnDownDisclosure:NO];
        if (currentPractice && tickingItem)
            [self timerButtonPressed:timerButton];

        [previousOpenSection setOpen:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection countofRowsToInsert];
        if ([previousOpenSection isNotes])
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenSectionIndex]];
        else if (countOfRowsToDelete > 0 && currentPractice) {
            for (NSInteger i = 0; i <= countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else if (countOfRowsToDelete > 0 && !currentPractice) {
            for (NSInteger i = 0; i < countOfRowsToDelete; i++)
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        } else {
            [previousOpenSection setOpen:NO];
        }
    }
    [statsTable beginUpdates];
    [statsTable deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    [statsTable endUpdates];
    UITableViewCell *visCell;
    if ([[statsTable visibleCells] count])
       visCell = [[statsTable visibleCells] objectAtIndex:0];
    else
        visCell = nil;
    [timerButton setImage:[UIImage imageNamed:@"startTimerLarge.png"] forState:UIControlStateNormal];
    if ((section > 1 && ![[statsTable visibleCells] containsObject: 
                         [statsTable cellForRowAtIndexPath:
                          [NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] -1 inSection:section]]]) || visCell.frame.origin.y > statsTable.frame.size.height - 62)
        [statsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[statsTable numberOfRowsInSection:section] - 1 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    if (section < 2)
        [statsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)sectionClosed:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    [sectionInfo.headerView turnDownDisclosure:NO];
    [sectionInfo setOpen:NO];
    if (currentPractice && tickingItem)
        [self timerButtonPressed:timerButton];
    
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

- (void)deleteSection:(NSInteger)section
{
    [self becomeFirstResponder];
    /*if (section == 0)
    {
    }*/
    if (section > 1 && currentPractice)
    {
        [self closeSections];
        if ([[sectionInfoArray objectAtIndex:section] isNotes])
            [[[SessionStore defaultStore] mySession] setSessionNotes:nil];
        else {
            //id item = [[[[SessionStore defaultStore] mySession] pieceSession] objectAtIndex:section - 2];
            [[[[SessionStore defaultStore] mySession] pieceSession] removeObjectAtIndex:section - 2];
            if (![[[SessionStore defaultStore] mySession] pieceSession])
            {
                [[[SessionStore defaultStore] mySession] setPieceSession:[[NSMutableOrderedSet alloc] init]];
            }
        }
        [sectionInfoArray removeObjectAtIndex:section];
        for (int i = section; i < [sectionInfoArray count]; i++)
        {
            NSInteger currentSection = [[[sectionInfoArray objectAtIndex:i] headerView] section];
            SectionHeaderView *currentHeader = [[sectionInfoArray objectAtIndex:i] headerView];
            [currentHeader setSection:(currentSection - 1)];
        }
        [statsTable beginUpdates];
        [statsTable deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [statsTable reloadData];
        [statsTable endUpdates];
        [self setOpenSectionIndex:NSNotFound];
        NSString *timeString = [NSString timeStringFromInt:[selectedSession calculateTotalTime]];
        [totalTime setText:timeString];

    }
}

@end
