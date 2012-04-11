//
//  OtherVC.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Session;

@interface OtherVC : UIViewController <UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSIndexPath *editItemPath;
@property (nonatomic, strong) Session *selectedSession;
- (id)initWithEditMode:(BOOL)_edit;


@end
