//
//  PiecesPracticedToday.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Session;

@interface PiecesPickerVC : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSIndexPath *editItemPath;
@property (nonatomic, strong) Session *selectedSession;
- (IBAction)backToPieces:(id)sender;

@end
