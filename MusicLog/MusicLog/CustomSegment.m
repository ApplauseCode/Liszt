//
//  CustomSegment.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomSegment.h"

@interface CustomSegment ()
@property (nonatomic, strong) UIImageView *arrowIndicator;
@property (nonatomic, strong) NSArray *arrowLocations;
@end

@implementation CustomSegment
@synthesize bgImageView, segments, touchDownImages, selectedIndex, arrowIndicator, indicatorXOffset, arrowLocations;

- (id)initWithPoint:(CGPoint)point
   numberOfSegments:(NSInteger)_segments
    touchDownImages:(NSArray *)_touchDownImages
  andArrowLocations:(NSArray *)_arrowLocations;
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, [[_touchDownImages objectAtIndex:0] size].width, [[_touchDownImages objectAtIndex:0] size].height)];
    if (self)
    {
        arrowLocations = _arrowLocations;
        arrowIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SegmentArrow.png"]];
        touchDownImages = _touchDownImages;
        segments = _segments;
        bgImageView = [[UIImageView alloc] initWithImage:[touchDownImages objectAtIndex:0]];
        [self addSubview:bgImageView];
        indicatorXOffset = 4;
        if (arrowLocations)
        {
            [arrowIndicator setCenter:CGPointMake([[_arrowLocations objectAtIndex:0] floatValue] , indicatorXOffset)];
        }
        else
        {
            float widthOfSegment = [self frame].size.width / segments;
            [arrowIndicator setCenter:CGPointMake((widthOfSegment * (selectedIndex + 1)) - (widthOfSegment/2), indicatorXOffset)];
        }
        [self addSubview:arrowIndicator];

    }
    NSLog(@"x: %f y:%f w:%f h:%f",self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    return self;
}

- (void)setIndicatorXOffset:(NSInteger)_indicatorXOffset
{
    indicatorXOffset = _indicatorXOffset;
    [arrowIndicator setCenter:CGPointMake(arrowIndicator.center.x, indicatorXOffset)];
}

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    return YES;  
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    NSLog(@"%f", [touch locationInView:self].x);
    float widthOfSegment = [self frame].size.width / segments;
    selectedIndex = [touch locationInView:self].x / widthOfSegment;
    NSLog(@"%i", selectedIndex);
    [UIView animateWithDuration:0.3 animations:^{
        if (arrowLocations)
            [arrowIndicator setCenter:CGPointMake([[arrowLocations objectAtIndex:selectedIndex] floatValue], arrowIndicator.center.y)];
        else
            [arrowIndicator setCenter:CGPointMake((widthOfSegment * (selectedIndex + 1)) - (widthOfSegment/2), arrowIndicator.center.y)];
        [bgImageView setImage:[touchDownImages objectAtIndex:selectedIndex]];
    } completion:^(BOOL finished) {
    }];
}
@end
