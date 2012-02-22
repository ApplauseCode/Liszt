//
//  CustomSegment.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegment : UIView
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, assign) NSInteger segments;
@property (nonatomic, strong) NSArray *touchDownImages;
@property (nonatomic, readonly, assign) NSInteger selectedIndex;

- (id)initWithPoint:(CGPoint)point
   numberOfSegments:(NSInteger)_segments
 andTouchDownImages:(NSArray *)_touchDownImages;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end
