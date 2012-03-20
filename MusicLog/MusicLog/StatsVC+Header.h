//
//  StatsVC+Header.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsVC.h"
@class CustomSectionMove;
@class AllGesturesRecognizer;

@interface StatsVC (Header) <CustomSectionMoveDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
- (void)getRidOfNotes:(id)sender;

@end
