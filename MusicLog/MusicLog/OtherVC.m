//
//  OtherVC.m
//  Liszt
//
//  Created by Kyle Rosenbluth on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OtherVC.h"
#import "SessionStore.h"
#import "Session.h"
#import "Other.h"

@interface OtherVC ()
@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UITextField *subTitleField;
@property (nonatomic, strong) IBOutlet UITextView *descriptionView;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UITapGestureRecognizer *viewTap;
- (IBAction)saveToStore:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)addOther;
- (void)editOther;
@end

@implementation OtherVC
@synthesize titleField;
@synthesize subTitleField;
@synthesize descriptionView;
@synthesize editMode;
@synthesize editItemPath;
@synthesize selectedSession;
@synthesize viewTap;

- (id)initWithEditMode:(BOOL)_edit
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        editMode = _edit;
    }
    return self;
    
}

- (void)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [titleField setDelegate:self];
    titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [titleField setBorderStyle:UITextBorderStyleNone];
    [titleField setPlaceholder:@"Title"];
    [subTitleField setDelegate:self];
    subTitleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [subTitleField setBorderStyle:UITextBorderStyleNone];
    [subTitleField setPlaceholder:@"SubTitle"];
    
    [descriptionView setDelegate:self];
    
    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:viewTap];
    [viewTap setEnabled:NO];
    
    if (editMode && editItemPath && selectedSession)
    {
        Other *otherToEdit;
        otherToEdit = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
        [titleField setText:[otherToEdit title]];
        [subTitleField setText:[otherToEdit subTitle]];
        [descriptionView setText:[otherToEdit description]];
    }
    
    
}

- (void)saveToStore:(id)sender
{
    if (!editMode)
        [self addOther];
    else
        [self editOther];
}

- (void)addOther
{
    Other *createdOther = [[Other alloc] init];
    SessionStore *store = [SessionStore defaultStore];
    [createdOther setTitle:[titleField text]];
    [createdOther setSubTitle:[subTitleField text]];
    [createdOther setDescription:[descriptionView text]];
    [[[store mySession] pieceSession] addObject:createdOther];
    
    UIImageView *hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUD.png"]];
    [hud setCenter:CGPointMake(160, 220)];
    [hud setAlpha:0];
    UILabel *text = [[UILabel alloc] init];
    [text setBounds:CGRectMake(0, 0, 90, 80)];
    [text setCenter:CGPointMake(hud.frame.size.width/2, hud.frame.size.height/2)];
    [text setNumberOfLines:0];
    [text setText:@"Other Item Added"];
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

- (void)editOther
{
    Other *editedOther = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
    
    [editedOther setTitle:[titleField text]];
    [editedOther setSubTitle:[subTitleField text]];
    [editedOther setDescription:[descriptionView text]];
    [[selectedSession pieceSession] replaceObjectAtIndex:[editItemPath section] - 2 withObject:editedOther];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [viewTap setEnabled:YES];
    textField.placeholder = nil;
    textField.center = CGPointMake(textField.center.x, textField.center.y-2);
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [viewTap setEnabled:NO];
    if (!titleField.placeholder)
        titleField.placeholder = @"Title";
    else if (!subTitleField.placeholder)
        subTitleField.placeholder = @"SubTitle";
    textField.center = CGPointMake(textField.center.x, textField.center.y+2);
    
}

- (void)dismissKeyboard
{
    [titleField resignFirstResponder];
    [subTitleField resignFirstResponder];
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



@end
