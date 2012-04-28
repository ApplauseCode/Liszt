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
#import "NotesPickerVC.h"
#import "StatsVC.h"

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

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    if (textViewCanEdit)
    {
        NotesPickerVC *n = [[NotesPickerVC alloc] initWithEditMode:YES];
        [root presentModalViewController:n animated:YES];
        [(StatsVC *)root closeSections];
        [(StatsVC *)root stopAllTimers];
    }
    return NO;
}
@end
