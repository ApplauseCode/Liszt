//
//  StatsView.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StatsViewHitTestDelegate;

@interface StatsView : UIView
@property (nonatomic, weak) id <StatsViewHitTestDelegate> delegate;
@end

@protocol StatsViewHitTestDelegate <NSObject>

@optional
- (UIView *)hitWithPoint:(CGPoint)point;

@end
