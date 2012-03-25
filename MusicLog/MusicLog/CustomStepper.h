//
//  CustomStepper.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/11/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//



#import <UIKit/UIKit.h>

int tempoRange(int x);

@protocol CustomStepperDelegate;

@interface CustomStepper : UIControl

@property(nonatomic, assign) NSUInteger tempo;
@property (nonatomic, assign) BOOL canBeNone;
@property (nonatomic, weak) id <CustomStepperDelegate> delegate;


- (id)initWithPoint:(CGPoint)point label:(UILabel *)label andCanBeNone:(BOOL)_canBeNone;
- (void)timerFireMethod:(NSTimer*)theTimer;

@end

@protocol CustomStepperDelegate <NSObject>
@optional
- (void)valueChanged;

@end