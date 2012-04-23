//
//  NotesPickerVC.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesPickerVC.h"
#import "SessionStore.h"
#import "Session.h"
#import "UIView+HUDAnimation.h"

@interface NotesPickerVC ()
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
- (void)addNotes:(UIButton *)sender;
- (void)goBack;
@end

@implementation NotesPickerVC
@synthesize notesTextView;
@synthesize backButton;
@synthesize addButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [addButton addTarget:self action:@selector(addNotes:) forControlEvents:UIControlEventTouchUpInside];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [notesTextView setFont:[UIFont fontWithName:@"ACaslonPro-Italic" size:18]];
    [notesTextView setDelegate:self];
}

- (void)addNotes:(UIButton *)sender
{
    [[[SessionStore defaultStore] mySession] setSessionNotes:[notesTextView text]];
    
    [UIView animateHUDWithText:@"Notes Added"];
}

- (void)goBack
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tap to add notes"])
        [textView setText:@""];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y - 60)];   
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
        [textView setText:@"Tap to add notes"];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y + 60)];   
    }];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)viewDidUnload
{
    [self setNotesTextView:nil];
    [self setBackButton:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
