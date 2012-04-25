//
//  PopupCell.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupCell.h"
@interface PopupCell ()
@property (nonatomic, strong) UIButton *button;
- (void)buttonPressed;
@end
@implementation PopupCell
@synthesize button, buttonTitle, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImage *buttonImg = [UIImage imageNamed:@"DropButton.png"];
        [self setFrame:CGRectMake(5, 0, buttonImg.size.width, buttonImg.size.height)];
        button = [[UIButton alloc] initWithFrame:self.frame];
        [button setCenter:self.center];
        [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
        [self addSubview:button];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)buttonPressed
{
    [[self delegate] cellButtonPressedAtIndex:self.tag];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setButtonTitle:(NSString *)title
{
    [button.titleLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:18]];
    [button.titleLabel setTextColor:[UIColor blackColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; 
    [button setTitle:title forState:UIControlStateNormal];
}

@end
