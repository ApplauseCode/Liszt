//
//  PopupCell.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupCellDelegate;

@interface PopupCell : UITableViewCell
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) id<PopupCellDelegate> delegate;

@end

@protocol PopupCellDelegate <NSObject>

- (void)cellButtonPressedAtIndex:(NSInteger)idx;

@end
