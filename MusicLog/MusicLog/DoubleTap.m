//
//  DoubleTap.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DoubleTap.h"

@implementation DoubleTap
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2)
        [delegate doubleTapped];
    else
        [super touchesBegan:touches withEvent:event];
}

@end
