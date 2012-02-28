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
#import "SessionStore.h"
#import "Session.h"
#import "CustomStepper.h"
#import "CustomSegment.h"
#import "ACchooser.h"
#import "UIColor+YellowTextColor.h"

@interface ScalePickerVC ()
{
    IBOutlet UIButton *addScaleButton;
    IBOutlet UILabel *tempoLabel;
    IBOutlet UILabel *tempoTextLabel;
    IBOutlet UILabel *octavesLabel;
    
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

@end
@implementation ScalePickerVC
@synthesize tonicArray;

- (id)initWithIndex:(NSUInteger)idx
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
        [self setTitle:@"ScalePickerVC"];
//    unichar utf8char = 1D15D;
//    char chars[4];
//    if (utf8char > 65535) {
//        chars[0] = (utf8char >> 16) & 255;
//        chars[1] = (utf8char >> 8) & 255;
//        chars[2] = utf8char & 255; 
//        chars[3] = 0x00;
//    } else if (utf8char > 127) {
//        chars[0] = (utf8char >> 8) & 255;
//        chars[1] = utf8char & 255; 
//        chars[2] = 0x00;
//    } else {
//        chars[0] = utf8char;
//        chars[1] = 0x00;
//    }
//    NSString *wholeNote = [[NSString alloc] initWithUTF8String:chars];
    tonicArray = [NSArray arrayWithObjects:@"Sharps", @"Flats", @"All", @"C",@"C\u266f/D\u266d",@"D",@"D\u266f/E\u266d",@"E",@"F",@"F\u266f/G\u266d",@"G",@"G\u266f/A\u266d",@"A",@"A\u266f/B\u266d",@"B", nil];
    rhythmArray = [NSArray arrayWithObjects:@"Whole", @"1/2", @"\u2669", @"\u266b", @"1/12", @"\u266c", @"1/32", @"1/64",@"Bursts", nil];

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
        tonicChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 90, 272, 32)];
        modeChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 161, 272, 32)];
        rhythmChooser = [[ACchooser alloc] initWithFrame:CGRectMake(24, 231, 272, 32)];
        NSArray *choosers = [NSArray arrayWithObjects:tonicChooser, modeChooser, rhythmChooser, nil];
        for (ACchooser *chooser in choosers)
        {
            [chooser setSelectedBackgroundColor:[UIColor clearColor]];
            [chooser setSelectedTextColor:[UIColor blackColor]];
            [chooser setCellColor:[UIColor clearColor]];
            [chooser setCellFont:[UIFont fontWithName:@"ACaslonPro-Regular" size:20]];
        }
        
    }
    return self;
}

#pragma mark -
#pragma mark === View lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [addScaleButton setTitle:@"Add" forState:normal];
    [octavesLabel setFont:[UIFont fontWithName:@"AcaslonPro-Regular" size:20]];
    [octavesLabel setText:@"Octaves"];
    
    stepper = [[CustomStepper alloc] initWithPoint:CGPointMake(175, 340) andLabel:tempoLabel];
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
    [tonicChooser setVariableCellWidth:NO];
    [self.view addSubview:tonicChooser.view];
    [self.view addSubview:modeChooser.view];
    [self.view addSubview:rhythmChooser.view];
    [tonicChooser setSelectedTextColor:[UIColor blueColor]];
    [modeChooser setSelectedTextColor:[UIColor blueColor]];
    [rhythmChooser setSelectedTextColor:[UIColor blueColor]];
}

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

- (IBAction)addScale:(id)sender
{
    int row = [tonicChooser selectedCellIndex];
    Scale *pickedScale = [[Scale alloc] init];
    SessionStore *store = [SessionStore defaultStore];
    if (index == 0)
        [pickedScale setMode:[modeChooser selectedCellIndex]];
    else if (index == 1)
        [pickedScale setMode:([modeChooser selectedCellIndex] + 4)];
    [pickedScale setRhythm:[rhythmChooser selectedCellIndex]];
    [pickedScale setOctaves:[octavesSegment selectedIndex] + 1];
    [pickedScale setTempo:stepper.tempo];
    
    NSMutableArray *sharps = [[NSMutableArray alloc] initWithCapacity:7];
    NSMutableArray *flats = [[NSMutableArray alloc] initWithCapacity:6];
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:12];
    int tonicNum = 0;
    
    if ([[[store mySession] scaleSession] respondsToSelector:@selector(addObject:)])
        NSLog(@"its mutable!");
    else
        NSLog(@"it aint mutable");
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

@end
