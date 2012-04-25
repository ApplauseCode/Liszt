//
//  PopupVC.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupCell.h"

@protocol PopupVCDelegate;
@interface PopupVC : UIViewController <UITableViewDelegate, UITableViewDataSource, PopupCellDelegate>
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) NSArray *staticCells;
@property (nonatomic, weak) id <PopupVCDelegate> delegate;
@property (nonatomic, strong) UITableView *staticTable;
- (id)initWithFrame:(CGRect)frame;
@end

@protocol PopupVCDelegate <NSObject>

- (void)cellSelectedAtIndex:(NSInteger)index;

@end
