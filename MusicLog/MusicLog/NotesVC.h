//
//  NotesVC.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Session;
@interface NotesVC : UIViewController <UITextViewDelegate>

- (id)initWithIndexPath:(NSIndexPath *)_indexPath session:(Session *)_session;

@end
