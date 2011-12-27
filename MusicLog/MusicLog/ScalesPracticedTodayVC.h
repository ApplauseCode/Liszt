//
//  ScalesPracticedToday.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScalePickerVC;
@interface ScalesPracticedTodayVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIScrollViewDelegate>
{
    ScalePickerVC *sp;
    NSTimer *timer;
    NSSet *zeroThroughNine;
    
    int seconds;
    int minutes;
    int timePracticed;
    int onlyOneTimer;
    
    UIButton *addButton;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIView *timerView;
    
    IBOutlet UIView *metronomeView;
    IBOutlet UITableView *scalesTableView;
    IBOutlet UIButton *startTimerButton;
    IBOutlet UIButton *resetTimerButton;
    IBOutlet UILabel *timerLabel;
}
@property (nonatomic, readonly) UITableView *scalesTableView;
@property (nonatomic, strong) IBOutlet UIButton *startTimerButton;
 
- (void)scalePicker:(id)sender;
- (void)clearAll:(id)sender;
- (void)finishedSession:(id)sender;

- (IBAction)startTimer:(id)sender;
- (IBAction)resetTimer:(id)sender;
- (void)timerFireMethod:(NSTimer*)theTimer;

//- (void)loadScrollViewWithPage:(int)page;

@end
