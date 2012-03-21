//
//  CustomSegment.h
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/18/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegment : UIControl
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, assign) NSInteger segments;
@property (nonatomic, strong) NSArray *touchDownImages;
@property (nonatomic, readonly, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger indicatorXOffset;


- (id)initWithPoint:(CGPoint)point
   numberOfSegments:(NSInteger)_segments
    touchDownImages:(NSArray *)_touchDownImages
  andArrowLocations:(NSArray *)_arrowLocations;
@end
