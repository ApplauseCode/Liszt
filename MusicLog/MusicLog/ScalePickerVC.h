//
//  ScalePicker.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
@class Scale;
@class CustomStepper;

@interface ScalePickerVC : UIViewController
@property (nonatomic, readonly, strong) NSArray *tonicArray;

- (id)initWithIndex:(NSUInteger)idx;
//- (IBAction)addScale:(id)sender;
- (void)backToScales:(id)sender;
- (void)repeatedScaleWarning;

@end
