//
//  NotesCell.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesCell.h"
#import "SessionStore.h"
#import "Session.h"

@implementation NotesCell
@synthesize textView;
@synthesize textViewCanEdit;
@synthesize root;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *im = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotesInputArea"]];
        [im setCenter:CGPointMake(160, im.center.y)];
        [self addSubview:im];
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 231, 127)];
        [textView setCenter:CGPointMake(160, textView.center.y)];
        [textView setDelegate:self];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setFont:[UIFont fontWithName:@"ACaslonPro-Italic" size:18]];
        [self addSubview:textView];
    }
    return self;
}

- (BOOL)textView:(UITextView *)aTextField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [aTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    if (textViewCanEdit)
        return YES;
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    NSLog(@"tableFrame:%@", NSStringFromCGPoint(root.center));
    [root scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[root numberOfSections] -1] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [root setCenter:CGPointMake(root.center.x, 50)];   
    }];

}

- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    [[[SessionStore defaultStore] mySession] setSessionNotes:[aTextView text]];
    [UIView animateWithDuration:0.25 animations:^{
        [root setCenter:CGPointMake(root.center.x, 270)];   
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
