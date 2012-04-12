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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 128)];
        [textView setDelegate:self];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:18]];
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


- (void)textViewDidEndEditing:(UITextView *)aTextView
{
    [[[SessionStore defaultStore] mySession] setSessionNotes:[aTextView text]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
