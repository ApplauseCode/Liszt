//
//  DoubleTap.h
//  MusicLog
//
//  Created by Kyle Rosenbluth on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubleTap : UIView
@property (nonatomic, strong) id delegate;
@end

@protocol DoubleTapDelegate

- (void)doubleTapped;

@end
