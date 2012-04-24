//
//  UIView+HUDAnimation.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+HUDAnimation.h"

@implementation UIView (HUDAnimation)

+ (void)animateHUDWithText:(NSString *)string
{
    UIImageView *hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUDDark.png"]];
    [hud setCenter:CGPointMake(160, 220)];
    [hud setAlpha:0];
    UILabel *text = [[UILabel alloc] init];
    [text setBounds:CGRectMake(0, 0, 90, 80)];
    [text setCenter:CGPointMake(hud.frame.size.width/2, hud.frame.size.height/2)];
    [text setNumberOfLines:0];
    [text setText:string];
    [text setFont:[UIFont systemFontOfSize:17]];
    [text setTextAlignment:UITextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setTextColor:[UIColor whiteColor]];
    [hud addSubview:text];
    [[UIApplication sharedApplication].delegate.window addSubview:hud];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [hud setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
                             [hud setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [hud removeFromSuperview];
                         }];
                     }];
}

@end
