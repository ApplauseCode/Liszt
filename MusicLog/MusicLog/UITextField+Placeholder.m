//
//  UITextField+Placeholder.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 3/4/12.
//  Copyright (c) 2012 __Applause Code__. All rights reserved.
//

#import "UITextField+Placeholder.h"

@implementation UITextField (Placeholder)


- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor blackColor] setFill];
    [self.placeholder drawInRect:rect
                        withFont:self.font
                   lineBreakMode:UILineBreakModeTailTruncation
                       alignment:self.textAlignment];
}

@end
