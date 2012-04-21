//
//  NotesCell.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotesCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL textViewCanEdit;
@property (nonatomic, strong) UITableView *root;
@end
