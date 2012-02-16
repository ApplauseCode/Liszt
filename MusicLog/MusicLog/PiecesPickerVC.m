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
#import "SessionStore.h"
#import "Session.h"
#import "StatsVC.h"
#import "UIColor+YellowTextColor.h"

@interface PiecesPickerVC ()
{
    ACchooser *keyChooser;
    NSArray *keys;
    CustomStepper *tempoStepper;
    UITapGestureRecognizer *viewTap;
    UITextField *titleLabel;
    UITextField *composerLabel;
}
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempoTextLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSeg;

- (IBAction)addPiece:(id)sender;
- (void)dismissKeyboard;


@end

@implementation PiecesPickerVC
@synthesize tempoLabel;
@synthesize modeSeg;
@synthesize tempoTextLabel;

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
    SessionStore *store = [SessionStore defaultStore];
    [createdPiece setTitle:[titleLabel text]];
    [createdPiece setComposer:[composerLabel text]];
    [createdPiece setTempo:[tempoStepper tempo]];
    [createdPiece setMajor:[modeSeg selectedSegmentIndex]];
    [createdPiece setPieceKey:[keyChooser selectedCellIndex]];
    [[[store mySession] pieceSession] addObject:createdPiece];    
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
    
    titleLabel = [[UITextField alloc] initWithFrame:CGRectMake(33, 95, 280, 31)];
    [titleLabel setBorderStyle:UITextBorderStyleNone];
    composerLabel = [[UITextField alloc] initWithFrame:CGRectMake(33, 164, 280, 31)];
    [composerLabel setBorderStyle:UITextBorderStyleNone];
    

    keyChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 231, 272, 32)];
    [keyChooser setSelectedBackgroundColor:[UIColor clearColor]];
    [keyChooser setSelectedTextColor:[UIColor blackColor]];
    [keyChooser setCellColor:[UIColor clearColor]];
    [keyChooser setCellFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];

    viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:viewTap];
    [viewTap setEnabled:NO];
    tempoStepper = [[CustomStepper alloc] initWithPoint:CGPointMake(7, 260) andLabel:tempoLabel];
    
    tempoStepper = [[CustomStepper alloc] initWithPoint:CGPointMake(175, 340) andLabel:tempoLabel];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [viewTap setEnabled:YES];
    textField.center = CGPointMake(textField.center.x, textField.center.y-2);

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [viewTap setEnabled:NO];
    textField.center = CGPointMake(textField.center.x, textField.center.y+2);

}

- (void)dismissKeyboard
{
    [titleLabel resignFirstResponder];
    [composerLabel resignFirstResponder];
}

@end
