//
//  ACchooser.h
//
//  Created by Kyle & Jeffrey Rosenbluth on 10/20/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <UIKit/UIKit.h>

CGFloat sum_2(CGFloat *a, int n);
@interface ACchooser : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIColor *cellColor;
@property (nonatomic, strong) UIFont *cellFont;
@property (nonatomic, strong) UIColor *cellTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, assign) BOOL variableCellWidth;

@property (nonatomic, assign, readonly) int selectedCellIndex;
@property (nonatomic, weak) id delegate;

// the designated intializer
- (id)initWithFrame:(CGRect)frame;

@end

@protocol ACchooserDelegate
@optional

- (void)chooserDidSelectCell:(ACchooser *)chooser;

@end