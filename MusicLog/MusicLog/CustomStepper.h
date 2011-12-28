//
//  CustomStepper.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>

int tempoRange(int x);

@protocol CustomStepperDelegate;

@interface CustomStepper : UIControl

@property NSUInteger tempo;
@property (nonatomic, weak) id <CustomStepperDelegate> delegate;


- (id)initWithPoint:(CGPoint)point andLabel:(UILabel *)label;
- (void)timerFireMethod:(NSTimer*)theTimer;

@end

@protocol CustomStepperDelegate <NSObject>
@optional
- (void)valueChanged;

@end