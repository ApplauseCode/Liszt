//
//  PiecesPracticedToday.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
//

#import "PiecesPickerVC.h"
#import "ACchooser.h"
#import "CustomStepper.h"
#import "Piece.h"
#import "SessionStore.h"
#import "Session.h"
#import "StatsVC.h"
#import "UIColor+YellowTextColor.h"
#import "CustomSegment.h"
#import "ModifiedTextField.h"
#import "UIView+HUDAnimation.h"
@interface PiecesPickerVC ()
{
    ACchooser *keyChooser;
    NSArray *keys;
    CustomStepper *tempoStepper;
    CustomSegment *majOrMin;
    UITapGestureRecognizer *viewTap;
    ModifiedTextField *titleField;
    ModifiedTextField *composerField;
}
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempoTextLabel;
@property (assign, nonatomic) BOOL editMode;
@property (weak, nonatomic) IBOutlet UIImageView *viewBG;

- (IBAction)saveToStore:(id)sender;
- (void)dismissKeyboard;
- (void)addPiece;
- (void)editPiece;


@end

@implementation PiecesPickerVC
@synthesize tempoLabel;
@synthesize editItemPath;
@synthesize selectedSession;
@synthesize tempoTextLabel;
@synthesize editMode;
@synthesize viewBG;
@synthesize addPieceButton;

- (id)initWithEditMode:(BOOL)_edit
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        editMode = _edit;
        [self setTitle:@"Pieces"];
        keys = [NSArray arrayWithObjects:@"C",@"C\u266f",@"D\u266d", @"D", @"D\u266f",@"E\u266d",@"E",@"F",@"F\u266f",@"G\u266d",@"G",@"G\u266f",@"A\u266d",@"A",@"A\u266f",@"B\u266d",@"B", nil];     
    }
    return self;

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)backToPieces:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    titleField = [[ModifiedTextField alloc] initWithFrame:CGRectMake(33, 95, 268, 31)];
    titleField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [titleField setBorderStyle:UITextBorderStyleNone];
    composerField = [[ModifiedTextField alloc] initWithFrame:CGRectMake(33, 164, 268, 31)];
    composerField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [composerField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [composerField setBorderStyle:UITextBorderStyleNone];
    
    UIImage *seg0 = [UIImage imageNamed:@"MajOrMin0.png"];
    UIImage *seg1 = [UIImage imageNamed:@"MajOrMin1.png"];
    
    NSArray *majOrMinImages = [NSArray arrayWithObjects:seg0, seg1, nil];
    NSNumber *loc0 = [NSNumber numberWithFloat:48];
    NSNumber *loc1 = [NSNumber numberWithFloat:115];
    NSArray *segArrowLocs = [NSArray arrayWithObjects:loc0, loc1, nil];
                              
    majOrMin = [[CustomSegment alloc] initWithPoint:CGPointMake(82, 286)
                                   numberOfSegments:2
                                    touchDownImages:majOrMinImages
                                  andArrowLocations:segArrowLocs];
    [majOrMin setIndicatorXOffset:13];
    [self.view addSubview:majOrMin];
    keyChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 231, 272, 32)];
    [keyChooser setSelectedBackgroundColor:[UIColor clearColor]];
    [keyChooser setSelectedTextColor:[UIColor blackColor]];
    [keyChooser setCellColor:[UIColor clearColor]];
    [keyChooser setCellFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];

    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [viewTap setDelegate:self];
    [self.view addGestureRecognizer:viewTap];
    [viewTap setEnabled:NO];
    
    tempoStepper = [[CustomStepper alloc] initWithPoint:CGPointMake(175, 340) label:tempoLabel andCanBeNone:YES];
    [self.view addSubview:tempoStepper];
    
    [tempoTextLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:11]];
    [tempoTextLabel setTextColor:[UIColor yellowTextColor]];
    
    NSArray *textFields = [NSArray arrayWithObjects:titleField, composerField, nil];
    for (UITextField *field in textFields)
    {
        [field setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:19]];
        [field setDelegate:self];
        [field setReturnKeyType:UIReturnKeyDone];
    }   
    [titleField setPlaceholder:@"Piece Name"];
    [composerField setPlaceholder:@"Composer"];
    [keyChooser setDataArray:keys];
    [self.view addSubview:keyChooser.view];
    [self.view addSubview:tempoStepper];
    [self.view addSubview:titleField];
    [self.view addSubview:composerField];
    
    // set defaults
    [majOrMin setSelectedIndex:1];
    
    if (editMode && editItemPath && selectedSession)
    { 
        [addPieceButton setImage:[UIImage imageNamed:@"saveEditsButton.png"] forState:UIControlStateNormal];
        [viewBG setImage:[UIImage imageNamed:@"EditBGR8.png"]];
        Piece *itemToEdit;
        itemToEdit = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
        [titleField setText:[itemToEdit title]];
        [composerField setText:[itemToEdit composer]];
        [majOrMin setSelectedIndex:[itemToEdit major]];
        [tempoStepper setTempo:[itemToEdit tempo]];
        [keyChooser setSelectedCellIndex:[itemToEdit pieceKey]];
    }

}

- (void)saveToStore:(id)sender
{
    if (!editMode)
        [self addPiece];
    else 
        [self editPiece];
}

- (void)addPiece
{
    if (![titleField text])
        [titleField setText:@""];
    if (![composerField text])
        [composerField setText:@""];
    Piece *createdPiece = [[Piece alloc] init];
    SessionStore *store = [SessionStore defaultStore];
    [createdPiece setTitle:[titleField text]];
    [createdPiece setComposer:[composerField text]];
    [createdPiece setTempo:[tempoStepper tempo]];
    [createdPiece setMajor:[majOrMin selectedIndex]];
    [createdPiece setPieceKey:[keyChooser selectedCellIndex]];
    [[[store mySession] pieceSession] addObject:createdPiece];
    
    [UIView animateHUDWithText:@"Piece Added"];
}

- (void)editPiece
{
    Piece *editedItem = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
    
    [editedItem setTitle:[titleField text]];
    [editedItem setComposer:[composerField text]];
    [editedItem setMajor:[majOrMin selectedIndex]];
    [editedItem setTempo:[tempoStepper tempo]];
    [editedItem setPieceKey:[keyChooser selectedCellIndex]];
    [[selectedSession pieceSession] replaceObjectAtIndex:[editItemPath section] - 2 withObject:editedItem];
    [UIView animateHUDWithText:@"Piece Edited"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    titleField = nil;
    composerField = nil;
    [self setViewBG:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
    else if (!composerField.placeholder)
        composerField.placeholder = @"Composer";
    textField.center = CGPointMake(textField.center.x, textField.center.y+2);

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (CGRectContainsPoint(titleField.frame, [touch locationInView:self.view]) || CGRectContainsPoint(composerField.frame, [touch locationInView:self.view]))
        return NO;
    return YES;
}
- (void)dismissKeyboard
{
    [titleField resignFirstResponder];
    [composerField resignFirstResponder];
}

@end
