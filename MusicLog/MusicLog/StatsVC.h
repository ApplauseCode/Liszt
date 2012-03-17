//
//  StatsVc.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"
#import "CustomStepper.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomSectionMove.h"
@class Timer;
@class Metronome;
@class Session;
@class TimerCell;

@interface StatsVC : UIViewController <SectionHeaderViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, CustomStepperDelegate, UIAlertViewDelegate>
{
    Session *selectedSession;
    NSMutableArray *sectionInfoArray;
    IBOutlet UITableView *statsTable;
    TimerCell *tCell;
    UIButton *timerButton;
    BOOL currentPractice;
    BOOL isTiming;
    UILabel *totalTime;
    CustomSectionMove *sectionMover;
}
- (void)blockAlertView:(BOOL)isYes;

@property (nonatomic)           NSUInteger tempo;
@property (nonatomic, strong)   Session *selectedSession;
@property (nonatomic, strong)   AVAudioPlayer *tickPlayer;
@property (nonatomic, strong)   CustomStepper *stepper;
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
@property (nonatomic, assign)   BOOL shouldDisplayTime;
@property (nonatomic) BOOL isTiming;
@property (nonatomic, strong) UILabel *totalTime;
@property (nonatomic, strong) CustomSectionMove *sectionMover;



- (void)makeMenu;
- (void)makeMetronome;
- (void)setUpScalesAndArpeggios;
- (void)dateChanged;
- (void)hideMenu:(id)sender;
- (void)closeSections;
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(SectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;
- (void)toggleTimer:(int)section;
- (void)timerButtonPressed:(id)sender;
- (NSInteger)calculateTotalTime;

@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UIView *metronomeView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) UIButton *timerButton;
@property (strong, nonatomic) IBOutlet UITableView *statsTable;
@property (strong, nonatomic) IBOutlet UILabel *selSessionDisplay;
@property (strong, nonatomic) IBOutlet UIButton *chooseDateButton;
@property (strong, nonatomic) IBOutlet UIView *myPopover;
@property (strong, nonatomic) IBOutlet UIButton *chooseScalesButton;
@property (strong, nonatomic) IBOutlet UIButton *chooseArpsButton;
@property (strong, nonatomic) IBOutlet UIButton *choosePiecesButton;
@property (strong, nonatomic) IBOutlet UILabel *tempoNameLabel;

- (IBAction)startMetronome:(id)sender;
- (IBAction)slideDown:(id)sender;
- (IBAction)showMenu:(id)sender;
- (IBAction)presentPickerView:(id)sender;
@end
