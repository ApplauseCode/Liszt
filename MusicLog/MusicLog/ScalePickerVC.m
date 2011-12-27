//
//  ScalePicker.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScalePickerVC.h"
#import "AppDelegate.h"
#import "Scale.h"
#import "ScaleStore.h"
#import "CustomStepper.h"
#import "ACchooser.h"

@interface ScalePickerVC ()
{
    IBOutlet UISegmentedControl *octavesSegmentedControl;
    IBOutlet UIButton *addScaleButton;
    IBOutlet UILabel *tempoLabel;
    IBOutlet UILabel *octavesLabel;
    
    NSUInteger index;
    BOOL buttonDown;
    double timeElapsed;
    
    NSTimer *timer;
    CustomStepper *stepper;
    //NSArray *tonicArray;
    NSArray *modeArray;
    NSArray *rhythmArray;
    NSString *tempoString;
    
    ACchooser *modeChooser;
    ACchooser *tonicChooser;
    ACchooser *rhythmChooser;
}
- (void)sessionSave;

@end
@implementation ScalePickerVC
@synthesize tonicArray;

- (id)initWithIndex:(NSUInteger)idx
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
        [self setTitle:@"ScalePickerVC"];
    tonicArray = [NSArray arrayWithObjects:@"Sharps", @"Flats", @"All", @"C",@"D Flat",@"D",@"E Flat",@"E",@"F",@"G Flat",@"G",@"A Flat",@"A",@"B Flat",@"B", nil];
    rhythmArray = [NSArray arrayWithObjects:@"Whole", @"1/2", @"1/4", @"1/8", @"1/12", @"1/16", @"1/32", @"1/64",@"Bursts", nil];

    {
        switch (idx) {
            case 0:
                modeArray = [NSArray arrayWithObjects:@"Major", @"Natural Minor", @"Melodic Minor", @"Harmonic Minor", nil];
                break;
            case 1:
                modeArray = [NSArray arrayWithObjects:@"Major", @"Minor", @"Major 7", @"Dominant 7", @"Minor 7", @"Half Dim 7", @"Dim 7", nil];
                break;
        }
        index = idx;
        tonicChooser = [[ACchooser alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        modeChooser = [[ACchooser alloc] initWithFrame:CGRectMake(0, 90, 320, 44)];
        rhythmChooser = [[ACchooser alloc] initWithFrame:CGRectMake(0, 160, 320, 44)];
        
    }
    return self;
}

#pragma mark -
#pragma mark === View lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Create a bar button item to take you back to the main page
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToScales:)];
    self.navigationItem.leftBarButtonItem = back;
    
    [addScaleButton setTitle:@"Add" forState:normal];
    [octavesLabel setText:@"Octaves"];
    
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(30, 300) andLabel:tempoLabel];
    [self.view addSubview:stepper];
    
    [tonicChooser setDataArray:tonicArray];
    [modeChooser setDataArray:modeArray];
    [rhythmChooser setDataArray:rhythmArray];
    [tonicChooser setVariableCellWidth:NO];
    [self.view addSubview:tonicChooser.view];
    [self.view addSubview:modeChooser.view];
    [self.view addSubview:rhythmChooser.view];
    [tonicChooser setSelectedTextColor:[UIColor blueColor]];
    [modeChooser setSelectedTextColor:[UIColor blueColor]];
    [rhythmChooser setSelectedTextColor:[UIColor blueColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self sessionSave];

}

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (IBAction)addScale:(id)sender
{
    int row = [tonicChooser selectedCellIndex];
    Scale *pickedScale = [[Scale alloc] init];
    ScaleStore *store = [ScaleStore defaultStore];
    if (index == 1)
        [pickedScale setMode:[modeChooser selectedCellIndex]];
    else if (index == 3)
        [pickedScale setMode:([modeChooser selectedCellIndex] + 4)];
    [pickedScale setRhythm:[rhythmChooser selectedCellIndex]];
    [pickedScale setOctaves:[octavesSegmentedControl selectedSegmentIndex] + 1];
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
                [sharps addObject:[pickedScale copy]];
            }
            if (index == 0)
                [store addScaleArray:sharps];
            else if (index == 1)
                [store addArpeggioArray:sharps];
            break;
        case 1: //flats
            for (int i = 0; i < 6; i++) {
                tonicNum = (5 * (i + 1)) % 12 + 3;
                [pickedScale setTonic:tonicNum];
                [flats addObject:[pickedScale copy]];
            }
            if (index == 0)
                [store addScaleArray:flats];
            else if (index == 1)
                [store addArpeggioArray:flats];
            break;
        case 2: //all
            for (int i = 0; i < 12; i++) {
                tonicNum = (i * 7) % 12 + 3;
                [pickedScale setTonic:tonicNum];
                [all addObject:[pickedScale copy]];
            }
            if (index == 0)
                [store addScaleArray:all];
            else if (index == 1)
                [store addArpeggioArray:all];
            break;
        default:
            [pickedScale setTonic:row];
            if (index == 0)
                [store addScale:[pickedScale copy]];
            else if (index == 1)
                [store addArpeggio:[pickedScale copy]];
            break;
    }
}

- (void)backToScales:(id)sender
{
    [self dismissModalViewControllerAnimated:YES]; 
}

- (void)sessionSave
{
        switch (index) {
            case 0:
                [[ScaleStore defaultStore] addScalesToSession];
                break;
            case 1:
                [[ScaleStore defaultStore] addArpeggiosToSession];
                break;
        }
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

@end
