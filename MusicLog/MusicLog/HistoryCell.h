//
//  HistoryCell.h
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/20/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "LisztCell.h"

@interface HistoryCell : LisztCell

@property (nonatomic, copy) NSString *titleLabel;
@property (nonatomic, copy) NSString *subTitleLabel;

- (void) updateTitle:(NSString *)_title subTitle:(NSString *)_subTitle;

@end
