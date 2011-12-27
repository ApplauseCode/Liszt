//
//  ScalesPracticedToday.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ScalesArpeggiosVC.h"
#import "ScalesPracticedCell.h"
#import "Scale.h"
#import "ScalePickerVC.h"
#import "AppDelegate.h"
#import "ScaleStore.h"
#import "CustomStepper.h"
#import "Session.h"
#import "Timer.h"
#import "Common.h"
#import "Piece.h"
#import "NSString+Number.h"

@interface ScalesArpeggiosVC () 
{
    ScalePickerVC *sp;
    CustomStepper *stepper;
    Timer *timer;
    
    TROOL isScales;
    NSUInteger tempo;
    NSUInteger index;
    
    UIButton *addButton;
    AVAudioPlayer *tickPlayer;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIView *metronomeView;
    IBOutlet UITableView *scalesTableView;
    IBOutlet UIButton *startTimerButton;
    IBOutlet UILabel *timerLabel;
    IBOutlet UIButton *metroButton;
    IBOutlet UIView *scrollViewMetro;
    IBOutlet UILabel *tempoLabel;
    DoubleTap *timerResetButton;
    
    UIView *sectionHeader;
    
    IBOutlet UILabel *sessionNumber;
    IBOutlet UILabel *sessionTime;
}

- (IBAction)newSession:(id)sender;
@end

@implementation ScalesArpeggiosVC

- (id)initForScales:(TROOL)s
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
    isScales = s;
        //prepare the audio players
        NSBundle *mainBundle = [NSBundle mainBundle];        
        NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick5" ofType:@"aif"]];
        tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:nil];
        [tickPlayer prepareToPlay];
    }
    
    return self;
}

- (id)init 
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) 
    {
    }
    return self; 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initForScales:kZERO];
} 

#pragma mark -
#pragma mark === View Lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [scalesTableView setRowHeight:42];
        UINib *nib = [UINib nibWithNibName:@"ScalesPracticedCell" bundle:nil];
        [scalesTableView registerNib:nib 
              forCellReuseIdentifier:@"ScalesPracticedCell"];

    // Double tap to reset
    timerResetButton = [[DoubleTap alloc] initWithFrame:CGRectMake(97, 15, 123, 38)];
    [timerResetButton setDelegate:self];
    [timerResetButton setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:timerResetButton];
    
    // Configure the appearance of buttons and labels
    [timerLabel setText:@"00:00:00"];
    [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
    [tempoLabel setText:[NSString stringWithFormat:@"%u bpm", stepper.tempo]];
    [metroButton setTitle:@"Start" forState:UIControlStateNormal];
    
    // set the scrolling bottom between metronome and timer
    [scrollView setFrame:CGRectMake(0.0, 343.0, 320.0, 68.0)];
    [scrollView setContentSize:CGSizeMake(640.0, 68.0)];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:self];
    [scrollView addSubview:startTimerButton];
    [scrollView addSubview:timerLabel];
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(224, 15) andLabel:tempoLabel];
    [scrollViewMetro addSubview:stepper];
    [pageControl setNumberOfPages:2];
    // find out what the current page of the scroll view is, and set the pagecontrol to that
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    timer = [[Timer alloc] initWithLabel:timerLabel];
    
    sectionHeader = [[[NSBundle mainBundle] loadNibNamed:@"CustomSectionHeader" owner:self options:nil] objectAtIndex:0];
    
    NSDateFormatter *time = [[NSDateFormatter alloc] init];
    [time setDateFormat:@"HH:mm"];
    NSString *timeString = [time stringFromDate:[[[ScaleStore defaultStore] mySession] date]];
    NSLog(@"%@", timeString);
    [sessionTime setText:timeString];
}

- (void)viewDidUnload
{
    scrollView = nil;
    pageControl = nil;
    metronomeView = nil;
    metroButton = nil;
    tempoLabel = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    index = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarIndex];
    [scalesTableView reloadData];
    [sessionNumber setText:[NSString stringWithInt:[[[ScaleStore defaultStore] sessions] count]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self sessionSave];
}

#pragma mark -
#pragma mark === Timer ===
#pragma mark -

- (IBAction)startTimer:(id)sender
{
    if ([[startTimerButton currentTitle] isEqual:@"Start"])
    {
        [timer startTimer];
        [startTimerButton setTitle:@"Stop" forState:UIControlStateNormal];        
    } 
    else if ([[startTimerButton currentTitle] isEqual:@"Stop"]) 
    {
        [timer stopTimer];
        [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)doubleTapped
{
    [timer resetTimer];
    [timerLabel setText:@"00:00:00"];
    [startTimerButton setTitle:@"Start" forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (void)sessionSave
{
    Session *mySession = [[ScaleStore defaultStore] mySession];
    switch (isScales) {
        case 0:
            [[ScaleStore defaultStore] addScalesToSession];
            [mySession setScaleTime:[timer elapsedTime]];
            break;
        case 1:
            [[ScaleStore defaultStore] addArpeggiosToSession];
            [mySession setArpeggioTime:[timer elapsedTime]];
            break;
        case 2:
            [[ScaleStore defaultStore] addPiecesToSession];
            [mySession setPieceTime:[timer elapsedTime]];
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)myScrollView
{
    if ([myScrollView isEqual:scrollView]) 
    {
        CGFloat pageWidth = myScrollView.frame.size.width;
        int page = floor((myScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [sectionHeader frame].size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //ScaleStore *store = [ScaleStore defaultStore];
    
    if (isScales == 0)
        return [[[ScaleStore defaultStore] scalesInSession] count];
    else if (isScales == 1)
        return [[[ScaleStore defaultStore] arpeggiosInSession] count];
    else if (isScales == 2)
        return [[[ScaleStore defaultStore] piecesInSession] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display the custom cell with the values set by the user in the scalePicker screen
    ScalesPracticedCell *cell = (ScalesPracticedCell *) [tableView
                                       dequeueReusableCellWithIdentifier:@"ScalesPracticedCell"];
    id entry;
    if (isScales == 0)
        entry = [[[ScaleStore defaultStore] scalesInSession] objectAtIndex:[indexPath row]];
    else if (isScales == 1)
        entry = [[[ScaleStore defaultStore] arpeggiosInSession] objectAtIndex:[indexPath row]];
    
    if (isScales == 0 || isScales == 1)
    {
        cell.tonicLabel.text = [entry tonicString];
        cell.modeLabel.text = [entry modeString];
        cell.rhythmLabel.text = [entry rhythmString];
        cell.speedLabel.text = [entry tempoString];
        cell.octavesLabel.text = [entry octavesString];
    }
    else if (isScales == 2)
    {
        entry = [[[ScaleStore defaultStore] piecesInSession] objectAtIndex:[indexPath row]];
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [scalesTableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSOrderedSet *removers;
        id removee;
        
        if (isScales == 0)
        {
         removers = [[ScaleStore defaultStore] scalesInSession];
        removee = [removers objectAtIndex:[indexPath row]];
        [[ScaleStore defaultStore] removeScale:removee];
        }
        else if (isScales == 1)
        {
            removers = [[ScaleStore defaultStore] arpeggiosInSession];
            removee = [removers objectAtIndex:[indexPath row]];
            [[ScaleStore defaultStore] removeArpeggio:removee];
        }
        else if (isScales == 2)
        {
            removers = [[ScaleStore defaultStore] piecesInSession];
            removee = [removers objectAtIndex:[indexPath row]];
            [[ScaleStore defaultStore] removePiece:removee];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark -
#pragma mark === Metronome ===
#pragma mark 

- (IBAction)startMetronome:(id)sender {
    static NSTimer *tempoTimer;
    if (tempoTimer)
    {
        [tempoTimer invalidate];
        tempoTimer = nil;
        [sender setTitle:@"Start" forState:UIControlStateNormal];
        return;
    }
    [sender setTitle:@"Stop" forState:UIControlStateNormal];
    double bpm;
    bpm = [self chooseBPM:stepper.tempo];
    
   tempoTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:bpm] interval:bpm target:self selector:@selector(tempoTimerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:tempoTimer forMode:NSRunLoopCommonModes];
}

- (void)tempoTimerFireMethod:(NSTimer *)aTimer
{
    [tickPlayer play];
}

- (double)chooseBPM:(double)bpm
{
    return (60.0 / bpm);
}

#pragma mark -
#pragma mark === Custom Section Header ===
#pragma mark -

- (void)newSession:(id)sender
{
    ScaleStore *store = [ScaleStore defaultStore];
    [store addSession];
    [sessionNumber setText:[NSString stringWithInt:[[store sessions] count]]];
    
    NSDateFormatter *time = [[NSDateFormatter alloc] init];
    [time setDateFormat:@"HH:mm"];
    NSString *timeString = [time stringFromDate:[[store mySession] date]];
    NSLog(@"%@", timeString);
    [sessionTime setText:timeString];
}

- (IBAction)clearAll:(id)sender
{
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to erase all of your scales?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [warning show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[ScaleStore defaultStore] clearAll];
        [scalesTableView reloadData];
        [scalesTableView setRowHeight:42];
    }
}


@end