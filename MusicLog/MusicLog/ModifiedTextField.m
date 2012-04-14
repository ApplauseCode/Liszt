//
//  ModifiedTextField.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModifiedTextField.h"

@implementation ModifiedTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor blackColor] setFill];
    [self.placeholder drawInRect:rect
                        withFont:self.font
                   lineBreakMode:UILineBreakModeTailTruncation
                       alignment:self.textAlignment];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect upFive = CGRectMake(bounds.origin.x - 2, bounds.origin.y - 5, bounds.size.width, bounds.size.height);
    return [super clearButtonRectForBounds:upFive];
}

@end
