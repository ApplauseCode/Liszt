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
#import "ModifiedTextField.h"
#import "UIView+HUDAnimation.h"

@interface OtherVC ()
@property (nonatomic, strong) ModifiedTextField *titleField;
@property (nonatomic, strong) ModifiedTextField *subTitleField;
@property (nonatomic, strong) IBOutlet UITextView *otherDescriptionView;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UITapGestureRecognizer *viewTap;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *viewBG;
- (IBAction)saveToStore:(id)sender;
- (IBAction)goBack:(id)sender;
- (void)addOther;
- (void)editOther;
@end

@implementation OtherVC
@synthesize titleField;
@synthesize subTitleField;
@synthesize otherDescriptionView;
@synthesize editMode;
@synthesize editItemPath;
@synthesize selectedSession;
@synthesize viewTap;
@synthesize addButton;
@synthesize viewBG;

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
    UILabel *otherDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(109, 211, 95, 25)];
    [otherDescriptionLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [otherDescriptionLabel setText:@"otherDescription"];
    [otherDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:otherDescriptionLabel];
    
    titleField = [[ModifiedTextField alloc] initWithFrame:CGRectMake(33, 95, 268, 31)];
    [titleField setDelegate:self];
    titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [titleField setBorderStyle:UITextBorderStyleNone];
    [titleField setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [titleField setPlaceholder:@"Title"];
    [self.view addSubview:titleField];
    
    subTitleField = [[ModifiedTextField alloc] initWithFrame:CGRectMake(33, 164, 268, 31)];
    [subTitleField setDelegate:self];
    subTitleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [subTitleField setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [subTitleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [subTitleField setBorderStyle:UITextBorderStyleNone];
    [subTitleField setPlaceholder:@"SubTitle"];
    [self.view addSubview:subTitleField];
    
    [otherDescriptionView setDelegate:self];
    [otherDescriptionView setFont:[UIFont fontWithName:@"ACaslonPro-Italic" size:18]];
    
    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:viewTap];
    [viewTap setDelegate:self];
    [viewTap setEnabled:NO];
    
    if (editMode && editItemPath && selectedSession)
    {
        [addButton setImage:[UIImage imageNamed:@"saveEditsButton.png"] forState:UIControlStateNormal];
        [viewBG setImage:[UIImage imageNamed:@"EditBGR8.png"]];
        Other *otherToEdit;
        otherToEdit = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
        [titleField setText:[otherToEdit title]];
        [subTitleField setText:[otherToEdit subTitle]];
        [otherDescriptionView setText:[otherToEdit otherDescription]];
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
    [createdOther setOtherDescription:[otherDescriptionView text]];
    [[[store mySession] pieceSession] addObject:createdOther];
    
    [UIView animateHUDWithText:@"Other Item Added"];
}

- (void)editOther
{
    Other *editedOther = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
    
    [editedOther setTitle:[titleField text]];
    [editedOther setSubTitle:[subTitleField text]];
    [editedOther setOtherDescription:[otherDescriptionView text]];
    [[selectedSession pieceSession] replaceObjectAtIndex:[editItemPath section] - 2 withObject:editedOther];
    [UIView animateHUDWithText:@"Other Item Edited"];
}

- (void)viewDidUnload
{
    [self setViewBG:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tap to add notes"])
        [textView setText:@""];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y - 150)];   
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
        [textView setText:@"Tap to add notes"];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y + 150)];   
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (CGRectContainsPoint(titleField.frame, [touch locationInView:self.view]) || CGRectContainsPoint(subTitleField.frame, [touch locationInView:self.view]))
        return NO;
    return YES;
}


@end
