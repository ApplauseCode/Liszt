//
//  Calender.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderView.h"
#import "CustomStepper.h"
@class Timer;

@interface StatsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, SectionHeaderViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, CustomStepperDelegate>
@property (nonatomic, strong)   Timer *scaleTimer;
@property (nonatomic, strong)   Timer *arpeggioTimer;
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UIView *metronomeView;
//@property (strong, nonatomic) IBOutlet UIView *timerView;
//@property (strong, nonatomic) IBOutlet UIScrollView *metroTimeScroll;
//@property (strong, nonatomic) IBOutlet UIPageControl *scrollPage;
//@property (strong, nonatomic) IBOutlet UIButton *startTimer;
//@property (strong, nonatomic) IBOutlet UIButton *stopTimer;
@property (strong, nonatomic) UIButton *timerButton;
@property (strong, nonatomic) IBOutlet UITableView *statsTable;
@property (strong, nonatomic) IBOutlet UILabel *selSessionDisplay;
@property (strong, nonatomic) IBOutlet UIButton *chooseDateButton;
@property (strong, nonatomic) IBOutlet UIView *myPopover;
@property (strong, nonatomic) IBOutlet UIButton *chooseScalesButton;
@property (strong, nonatomic) IBOutlet UIButton *chooseArpsButton;
@property (strong, nonatomic) IBOutlet UIButton *choosePiecesButton;

- (IBAction)startMetronome:(id)sender;
- (IBAction)slideDown:(id)sender;
- (IBAction)showMenu:(id)sender;
- (IBAction)addScales:(id)sender;
- (IBAction)addArpeggios:(id)sender;
- (IBAction)addPieces:(id)sender;
- (IBAction)newSession:(id)sender;
@end
