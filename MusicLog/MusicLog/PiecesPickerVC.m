//
//  PiecesPracticedToday.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PiecesPickerVC.h"
#import "ACchooser.h"
#import "CustomStepper.h"
#import "Piece.h"
#import "ScaleStore.h"
#import "StatsVC.h"

@interface PiecesPickerVC ()
{
    ACchooser *keyChooser;
    NSArray *keys;
    CustomStepper *tempoStepper;
    UITapGestureRecognizer *viewTap;
}
@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *composerLabel;
@property (strong, nonatomic) IBOutlet UITextField *opusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSeg;

- (void)sessionSave;

- (IBAction)addPiece:(id)sender;
- (void)backToPieces:(id)sender;
- (void)dismissKeyboard;


@end

@implementation PiecesPickerVC
@synthesize titleLabel;
@synthesize composerLabel;
@synthesize opusLabel;
@synthesize tempoLabel;
@synthesize modeSeg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Pieces"];
    keys = [NSArray arrayWithObjects:@"C",@"C Sharp/D Flat",@"D",@"D Sharp/E Flat",@"E",@"F",@"F Sharp/G Flat",@"G",@"G Sharp/A Flat",@"A",@"A Sharp/B Flat",@"B", nil];        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)addPiece:(id)sender
{
    Piece *createdPiece = [[Piece alloc] init];
    ScaleStore *store = [ScaleStore defaultStore];
    
    [createdPiece setTitle:[titleLabel text]];
    [createdPiece setComposer:[composerLabel text]];
    [createdPiece setOpus:[[opusLabel text] intValue]];
    [createdPiece setTempo:[tempoStepper tempo]];
    [createdPiece setMajor:[modeSeg selectedSegmentIndex]];
    [createdPiece setPieceKey:[keyChooser selectedCellIndex]];
    
    [store addPiece:createdPiece];
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
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToPieces:)];
    self.navigationItem.leftBarButtonItem = back;
    keyChooser = [[ACchooser alloc] initWithFrame:CGRectMake(0, 166, 320, 44)];
    
    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:viewTap];
    [viewTap setEnabled:NO];
    
    tempoStepper = [[CustomStepper alloc] initWithPoint:CGPointMake(7, 260) andLabel:tempoLabel];
    
    
    NSArray *texFields = [NSArray arrayWithObjects:titleLabel, composerLabel, opusLabel, nil];
    for (UITextField *field in texFields)
    {
        [field setDelegate:self];
        [field setReturnKeyType:UIReturnKeyDone];
    }
    [opusLabel setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    
    [keyChooser setDataArray:keys];
    [self.view addSubview:keyChooser.view];
    [self.view addSubview:tempoStepper];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self sessionSave];

   /* if ([[self parentViewController] isKindOfClass:[StatsVC class]])
    [[self parentViewController] modalViewDismissed];*/
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setComposerLabel:nil];
    [self setOpusLabel:nil];
    [self setModeSeg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)sessionSave
{
    [[ScaleStore defaultStore] addPiecesToSession];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [viewTap setEnabled:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [viewTap setEnabled:NO];
}

- (void)dismissKeyboard
{
    [titleLabel resignFirstResponder];
    [composerLabel resignFirstResponder];
    [opusLabel resignFirstResponder];
}

@end
