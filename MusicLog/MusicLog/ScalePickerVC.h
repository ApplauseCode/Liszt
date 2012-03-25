//
//  ScalePicker.h
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/12/11.
//  Copyright 2011 __Applause Code__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
@class Scale;
@class CustomStepper;
@class Session;

@interface ScalePickerVC : UIViewController
@property (nonatomic, readonly, strong) NSArray *tonicArray;
@property (nonatomic, strong) NSIndexPath *editItemPath;
@property (nonatomic, strong) Session *selectedSession;

- (id)initWithIndex:(NSUInteger)idx editPage:(BOOL)_editMode;
- (IBAction)saveToStore:(id)sender;
- (IBAction)backToScales:(id)sender;
- (void)repeatedScaleWarning;

@end
