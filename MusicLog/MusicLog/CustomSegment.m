//
//  CustomSegment.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomSegment.h"

@implementation CustomSegment
@synthesize bgImageView, segments, touchDownImages, selectedIndex;

- (id)initWithPoint:(CGPoint)point
   numberOfSegments:(NSInteger)_segments
           andTouchDownImages:(NSArray *)_touchDownImages  
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, [[_touchDownImages objectAtIndex:0] size].width, [[touchDownImages objectAtIndex:0] size].height)];
    if (self)
    {
        touchDownImages = _touchDownImages;
        segments = _segments;
        bgImageView = [[UIImageView alloc] initWithImage:[touchDownImages objectAtIndex:0]];
        [self addSubview:bgImageView];
    }
    return self;
}

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    return YES;  
//}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    float widthOfSegment = [self frame].size.width / segments;
    float bottomPoint = 0;
    float topPoint = widthOfSegment;
    for (int i = 0; i < segments; i++)
    {
        if ([touch locationInView:self].x > bottomPoint && [touch locationInView:self].x < topPoint)
        {
            [bgImageView setImage:[touchDownImages objectAtIndex:i]];
            selectedIndex = i;
            return;
        }
        else
        {
            bottomPoint = topPoint;
            topPoint += topPoint;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
