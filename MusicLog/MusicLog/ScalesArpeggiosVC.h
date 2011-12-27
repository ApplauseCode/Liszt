//
//  ScalesPracticedToday.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DoubleTap.h"
#import "Common.h"

@class ScalePickerVC;
@class CustomStepper;

@interface ScalesArpeggiosVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate, DoubleTapDelegate>

- (id)initForScales:(TROOL)s;
- (IBAction)clearAll:(id)sender;
- (IBAction)startTimer:(id)sender;
- (void)doubleTapped;

- (void)tempoTimerFireMethod:(NSTimer*)aTimer;
- (double)chooseBPM:(double)bpm;
- (IBAction)startMetronome:(id)sender;
- (void)sessionSave;

@end
