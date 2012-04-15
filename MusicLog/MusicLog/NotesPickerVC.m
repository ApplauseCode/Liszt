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
    [notesTextView setDelegate:self];
}

- (void)addNotes:(UIButton *)sender
{
    [[[SessionStore defaultStore] mySession] setSessionNotes:[notesTextView text]];
    
    UIImageView *hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUD.png"]];
    [hud setCenter:CGPointMake(160, 220)];
    [hud setAlpha:0];
    UILabel *text = [[UILabel alloc] init];
    [text setBounds:CGRectMake(0, 0, 90, 80)];
    [text setCenter:CGPointMake(hud.frame.size.width/2, hud.frame.size.height/2)];
    [text setNumberOfLines:0];
    [text setText:@"Notes Added"];
    [text setFont:[UIFont systemFontOfSize:17]];
    [text setTextAlignment:UITextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setTextColor:[UIColor whiteColor]];
    [hud addSubview:text];
    [self.view addSubview:hud];
    [UIView animateWithDuration:0.1
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

- (void)goBack
{
    [self dismissModalViewControllerAnimated:YES];
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
