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
#import "UITextField+Placeholder.h"

@interface PiecesPickerVC ()
{
    ACchooser *keyChooser;
    NSArray *keys;
    CustomStepper *tempoStepper;
    CustomSegment *majOrMin;
    UITapGestureRecognizer *viewTap;
    UITextField *titleLabel;
    UITextField *composerLabel;
}
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempoTextLabel;
@property (assign, nonatomic) BOOL editMode;

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
    if (editMode)
        [addPieceButton setBackgroundImage:[UIImage imageNamed:@"saveEditsButton.png"] forState:UIControlStateNormal];
    
    titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(33, 95, 280, 31)];
    titleLabel.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [titleLabel setBorderStyle:UITextBorderStyleNone];
    composerLabel = [[UITextField alloc] initWithFrame:CGRectMake(33, 164, 280, 31)];
    composerLabel.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [composerLabel setBorderStyle:UITextBorderStyleNone];
    
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
    [self.view addGestureRecognizer:viewTap];
    [viewTap setEnabled:NO];
    
    tempoStepper = [[CustomStepper alloc] initWithPoint:CGPointMake(175, 340) label:tempoLabel andCanBeNone:YES];
    [self.view addSubview:tempoStepper];
    
    [tempoTextLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:11]];
    [tempoTextLabel setTextColor:[UIColor yellowTextColor]];
    
    NSArray *textFields = [NSArray arrayWithObjects:titleLabel, composerLabel, nil];
    for (UITextField *field in textFields)
    {
        [field setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:19]];
        [field setDelegate:self];
        [field setReturnKeyType:UIReturnKeyDone];
    }   
    [titleLabel setPlaceholder:@"Piece Name"];
    [composerLabel setPlaceholder:@"Composer"];
    [keyChooser setDataArray:keys];
    [self.view addSubview:keyChooser.view];
    [self.view addSubview:tempoStepper];
    [self.view addSubview:titleLabel];
    [self.view addSubview:composerLabel];
    
    // set defaults
    [majOrMin setSelectedIndex:1];
    
    if (editMode && editItemPath && selectedSession)
    { 
        Piece *itemToEdit;
        itemToEdit = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
        [titleLabel setText:[itemToEdit title]];
        [composerLabel setText:[itemToEdit composer]];
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
    if (![titleLabel text])
        [titleLabel setText:@""];
    if (![composerLabel text])
        [composerLabel setText:@""];
    Piece *createdPiece = [[Piece alloc] init];
    SessionStore *store = [SessionStore defaultStore];
    [createdPiece setTitle:[titleLabel text]];
    [createdPiece setComposer:[composerLabel text]];
    [createdPiece setTempo:[tempoStepper tempo]];
    [createdPiece setMajor:[majOrMin selectedIndex]];
    [createdPiece setPieceKey:[keyChooser selectedCellIndex]];
    [[[store mySession] pieceSession] addObject:createdPiece];
    /* remove later and add X buttons to fields */
    [titleLabel setText:@""];
    [composerLabel setText:@""];
    
    UIImageView *hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUD.png"]];
    [hud setCenter:CGPointMake(160, 220)];
    [hud setAlpha:0];
    UILabel *text = [[UILabel alloc] init];
    [text setBounds:CGRectMake(0, 0, 90, 80)];
    [text setCenter:CGPointMake(hud.frame.size.width/2, hud.frame.size.height/2)];
    [text setNumberOfLines:0];
    [text setText:@"Piece Added"];
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

- (void)editPiece
{
    Piece *editedItem = [[selectedSession pieceSession] objectAtIndex:[editItemPath section] - 2];
    
    [editedItem setTitle:[titleLabel text]];
    [editedItem setComposer:[composerLabel text]];
    [editedItem setMajor:[majOrMin selectedIndex]];
    [editedItem setTempo:[tempoStepper tempo]];
    [editedItem setPieceKey:[keyChooser selectedCellIndex]];
    [[selectedSession pieceSession] replaceObjectAtIndex:[editItemPath section] - 2 withObject:editedItem];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   /* if ([[self parentViewController] isKindOfClass:[StatsVC class]])
    [[self parentViewController] modalViewDismissed];*/
}

- (void)viewDidUnload
{
    titleLabel = nil;
    composerLabel = nil;
   // [self setModeSeg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if (!titleLabel.placeholder)
        titleLabel.placeholder = @"Title";
    else if (!composerLabel.placeholder)
        composerLabel.placeholder = @"Composer";
    textField.center = CGPointMake(textField.center.x, textField.center.y+2);

}

- (void)dismissKeyboard
{
    [titleLabel resignFirstResponder];
    [composerLabel resignFirstResponder];
}

@end
