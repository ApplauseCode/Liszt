//
//  StatsView.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/17/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StatsViewDelegate;

@interface StatsView : UIView
@property (nonatomic, weak) id <StatsViewDelegate> delegate;
@end

@protocol StatsViewDelegate <NSObject>

@optional
- (UIView *)hitWithPoint:(CGPoint)point;
@end
