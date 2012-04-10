//
//  ScalePicker.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/12/11.
//  Copyright 2011 __Applause Code__. All rights reserved.
//

#import "ScalePickerVC.h"
#import "AppDelegate.h"
#import "Scale.h"
#import "SessionStore.h"
#import "Session.h"
#import "CustomStepper.h"
#import "CustomSegment.h"
#import "ACchooser.h"
#import "UIColor+YellowTextColor.h"
#import "DCRoundSwitch.h"
#define NONEDITTONICS 3
#define EXCLUSIVEARPMODES 4

@interface ScalePickerVC ()
{
    IBOutlet UIButton *addScaleButton;
    IBOutlet UILabel *tempoLabel;
    IBOutlet UILabel *tempoTextLabel;
    IBOutlet UILabel *octavesLabel;
//    IBOutlet UIButton *onOffButton;
    NSUInteger index;
    BOOL buttonDown;
    double timeElapsed;
    
    NSTimer *timer;
    CustomStepper *stepper;
    CustomSegment *octavesSegment;
    //NSArray *tonicArray;
    NSArray *modeArray;
    NSArray *rhythmArray;
    NSString *tempoString;
    
    ACchooser *modeChooser;
    ACchooser *tonicChooser;
    ACchooser *rhythmChooser;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *viewBG;
@property (assign, nonatomic) BOOL editMode;

- (void)addItem;
- (void)editItem;
@end
@implementation ScalePickerVC
@synthesize viewBG;
@synthesize tonicArray;
@synthesize editMode;
@synthesize editItemPath;
@synthesize selectedSession;

- (id)initWithIndex:(NSUInteger)idx editPage:(BOOL)_editMode
{
    // sharp: \u266f
    // flat: \u266d
    
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        editMode = _editMode;
        [self setTitle:@"ScalePickerVC"];
        
        if (editMode)
            tonicArray = [NSArray arrayWithObjects:@"  C  ",@"C\u266f/D\u266d",@"  D  ",@"D\u266f/E\u266d",@"  E  ",@"  F  ",@"F\u266f/G\u266d",@"  G  ",@"G\u266f/A\u266d",@"  A  ",@"A\u266f/B\u266d",@"  B  ", nil];
        else
            tonicArray = [NSArray arrayWithObjects:@"Sharps", @"Flats", @"All", @"  C  ",@"C\u266f/D\u266d",@"  D  ",@"D\u266f/E\u266d",@"  E  ",@"  F  ",@"F\u266f/G\u266d",@"  G  ",@"G\u266f/A\u266d",@"  A  ",@"A\u266f/B\u266d",@"  B  ", nil];
        rhythmArray = [NSArray arrayWithObjects:@"   w",@" h ",@" q ",@"ry",@"rty",@"dffg", nil];
        
        switch (idx) {
            case 0:
                modeArray = [NSArray arrayWithObjects:@"Major", @"Natural Minor", @"Melodic Minor", @"Harmonic Minor", nil];
                break;
            case 1:
                modeArray = [NSArray arrayWithObjects:@"Major", @"Minor", @"Major 7", @"Dominant 7", @"Minor 7", @"Half Dim 7", @"Dim 7", nil];
                break;
        }
        index = idx;
        tonicChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 90, 272, 32)];
        modeChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 161, 272, 32)];
        rhythmChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 228, 272, 32)];
        NSArray *choosers = [NSArray arrayWithObjects:tonicChooser, modeChooser, rhythmChooser, nil];
        for (ACchooser *chooser in choosers)
        {
            [chooser setSelectedBackgroundColor:[UIColor clearColor]];
            [chooser setSelectedTextColor:[UIColor blackColor]];
            [chooser setCellColor:[UIColor clearColor]];
            [chooser setCellFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
        }
        [rhythmChooser setCellFont:[UIFont fontWithName:@"Rhythms" size:24]];
        
    }
    return self;
}

#pragma mark -
#pragma mark === View lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (editMode)
        [addScaleButton setBackgroundImage:[UIImage imageNamed:@"saveEditsButton.png"] forState:UIControlStateNormal];
    [octavesLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
    [octavesLabel setText:@"OCTAVES"];
    
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(175, 340) label:tempoLabel andCanBeNone:YES];
    [stepper setCanBeNone:YES];
    [self.view addSubview:stepper];
    
    UIImage *oct0 = [UIImage imageNamed:@"OctavesSegment0.png"];
    UIImage *oct1 = [UIImage imageNamed:@"OctavesSegment1.png"];
    UIImage *oct2 = [UIImage imageNamed:@"OctavesSegment2.png"];
    UIImage *oct3 = [UIImage imageNamed:@"OctavesSegment3.png"];
    
    NSArray *octavesImages = [NSArray arrayWithObjects:oct0, oct1, oct2, oct3, nil];

    octavesSegment = [[CustomSegment alloc] initWithPoint:CGPointMake(20, 286)
                                         numberOfSegments:4
                                       touchDownImages:octavesImages
                                        andArrowLocations:nil];
    [self.view addSubview:octavesSegment];
    
    [tempoTextLabel setFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:11]];
    [tempoTextLabel setTextColor:[UIColor yellowTextColor]];
    
    [tonicChooser setDataArray:tonicArray];
    [modeChooser setDataArray:modeArray];
    [rhythmChooser setDataArray:rhythmArray];
    [self.view addSubview:tonicChooser.view];
    [self.view addSubview:modeChooser.view];
    [self.view addSubview:rhythmChooser.view];
    [tonicChooser setSelectedTextColor:[UIColor blueColor]];
    [modeChooser setSelectedTextColor:[UIColor blueColor]];
    [rhythmChooser setSelectedTextColor:[UIColor blueColor]];
    
    // setting defaults
    if (index == 0)
    {
        [tonicChooser setSelectedCellIndex:3];
        [rhythmChooser setSelectedCellIndex:3];
        [octavesSegment setSelectedIndex:3];
    }
    else if (index == 1)
    {
        [viewBG setImage:[UIImage imageNamed:@"arpeggiosBG.png"]];
        [tonicChooser setSelectedCellIndex:3];
        [modeChooser setSelectedCellIndex:3];
        [octavesSegment setSelectedIndex:3];
        [rhythmChooser setSelectedCellIndex:3];
    }
    
    if (editMode && editItemPath && selectedSession)
    { 
        Scale *itemToEdit;
        switch ([editItemPath section]) {
            case 0:
                itemToEdit = [[selectedSession scaleSession] objectAtIndex:[editItemPath row] - 1];
                break;
            case 1:
                itemToEdit = [[selectedSession arpeggioSession] objectAtIndex:[editItemPath row] - 1];
                break;
            default:
                break;
        }
        [tonicChooser setSelectedCellIndex:[itemToEdit tonic] - NONEDITTONICS];
        if (index == 0)
            [modeChooser setSelectedCellIndex:[itemToEdit scaleMode]];
        else
            [modeChooser setSelectedCellIndex:[itemToEdit scaleMode] - EXCLUSIVEARPMODES];
        [rhythmChooser setSelectedCellIndex:[itemToEdit rhythm]];
        [octavesSegment setSelectedIndex:[itemToEdit octaves] - 1];
        [stepper setTempo:[itemToEdit tempo]];
    }
}

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (IBAction)saveToStore:(id)sender
{
    if (!editMode)
        [self addItem];
    else
        [self editItem];

}

- (void)editItem
{
    Scale *editedItem = [[Scale alloc] init];
    if (index == 0)
        [editedItem setScaleMode:[modeChooser selectedCellIndex]];
    else if (index == 1)
        [editedItem setScaleMode:([modeChooser selectedCellIndex] + EXCLUSIVEARPMODES)];
    [editedItem setRhythm:[rhythmChooser selectedCellIndex]];
    [editedItem setOctaves:[octavesSegment selectedIndex] + 1];
    [editedItem setTempo:stepper.tempo];
    [editedItem setTonic:[tonicChooser selectedCellIndex] + NONEDITTONICS];
    [[selectedSession scaleSession] replaceObjectAtIndex:[editItemPath row] - 1 withObject:editedItem];
}

- (void)addItem
{
    int row = [tonicChooser selectedCellIndex];
    Scale *pickedScale = [[Scale alloc] init];
    SessionStore *store = [SessionStore defaultStore];
    if (index == 0)
        [pickedScale setScaleMode:[modeChooser selectedCellIndex]];
    else if (index == 1)
        [pickedScale setScaleMode:([modeChooser selectedCellIndex] + EXCLUSIVEARPMODES)];
    [pickedScale setRhythm:[rhythmChooser selectedCellIndex]];
    [pickedScale setOctaves:[octavesSegment selectedIndex] + 1];
    [pickedScale setTempo:stepper.tempo];
    
    NSMutableArray *sharps = [[NSMutableArray alloc] initWithCapacity:7];
    NSMutableArray *flats = [[NSMutableArray alloc] initWithCapacity:6];
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:12];
    int tonicNum = 0;
    switch (row) {
        case 0: //sharps
            for (int i = 0; i < 6; i++) {
                tonicNum = (i * 7) % 12 + 3;
                [pickedScale setTonic:tonicNum];
                [sharps addObject:[pickedScale mutableCopy]];
            }
            if (index == 0)
                [[[store mySession] scaleSession] addObjectsFromArray:sharps];
            else if (index == 1)
                [[[store mySession] arpeggioSession] addObjectsFromArray:sharps];
            break;
        case 1: //flats
            for (int i = 0; i < 6; i++) {
                tonicNum = (5 * (i + 1)) % 12 + 3;
                [pickedScale setTonic:tonicNum];
                [flats addObject:[pickedScale mutableCopy]];
            }
            if (index == 0)
                [[[store mySession] scaleSession] addObjectsFromArray:flats];
            else if (index == 1)
                [[[store mySession] arpeggioSession] addObjectsFromArray:flats];
            break;
        case 2: //all
            for (int i = 0; i < 12; i++) {
                tonicNum = (i * 7) % 12 + 3;
                [pickedScale setTonic:tonicNum];
                [all addObject:[pickedScale mutableCopy]];
            }
            if (index == 0)
                [[[store mySession] scaleSession] addObjectsFromArray:all];
            else if (index == 1)
                [[[store mySession] arpeggioSession] addObjectsFromArray:all];
            break;
        default:
            [pickedScale setTonic:row];
            if (index == 0)
                [[[store mySession] scaleSession] addObject:[pickedScale mutableCopy]];
            else if (index == 1)
                [[[store mySession] arpeggioSession] addObject:[pickedScale mutableCopy]];
            break;
    }
    UIImageView *hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LisztHUD.png"]];
    [hud setCenter:CGPointMake(160, 220)];
    [hud setAlpha:0];
    UILabel *text = [[UILabel alloc] init];
    [text setBounds:CGRectMake(0, 0, 90, 80)];
    [text setCenter:CGPointMake(hud.frame.size.width/2, hud.frame.size.height/2)];
    [text setNumberOfLines:0];
    switch (index) {
        case 0:
            [text setText:@"Scales Added"];
            break;
        default:
            [text setText:@"Arpeggios Added"];
            break;
    }
    [text setFont:[UIFont systemFontOfSize:17]];
    [text setTextAlignment:UITextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setTextColor:[UIColor whiteColor]];
    [hud addSubview:text];
    [self.view addSubview:hud];
    [UIView animateWithDuration:0.3
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

- (void)backToScales:(id)sender
{
    [self dismissModalViewControllerAnimated:YES]; 
}

- (void)repeatedScaleWarning
{
	// open an alert with an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You have already added a scale that is exactly the same as this one" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
 }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setViewBG:nil];
    [super viewDidUnload];
}
@end
