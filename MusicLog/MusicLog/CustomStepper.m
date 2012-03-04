//
//  CustomStepper.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomStepper.h"
#import "UIColor+YellowTextColor.h"

int tempoRange(int x)
{
    if (x < 30)
        return 30;
    else if (x > 320)
        return 320;
    else return x;
}

@interface CustomStepper ()
{
    UILabel *tempoLabel;
    UITouch *myTouch;
    NSTimer *timer;
    double timeElapsed;
    UIImageView *stepperBG;
}
@end
@implementation CustomStepper

@synthesize tempo;
@synthesize delegate;

- (id)initWithPoint:(CGPoint)point andLabel:(UILabel *)label
{
    self = [self initWithFrame:CGRectMake(point.x, point.y, 109.0, 62.0)];
    tempoLabel = label;
    stepperBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StepperRolls.png"]];
    [self addSubview:stepperBG];
    UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:23];
    [tempoLabel setFont:caslon];
    [tempoLabel setTextColor:[UIColor yellowTextColor]];
    tempo = 80;
    [tempoLabel setText:[NSString stringWithFormat:@"%u BPM", tempo]];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    myTouch = [touches anyObject];
    if ([myTouch locationInView:self].x >= ([self frame].size.width / 2))
        [stepperBG setImage:[UIImage imageNamed:@"StepperPlusDown.png"]];
    else
        [stepperBG setImage:[UIImage imageNamed:@"StepperMinusDown.png"]];

    timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    timeElapsed += [timer timeInterval];
    if (timeElapsed >= 0.5)
    {    
        if ([myTouch locationInView:self].x >= ([self frame].size.width / 2))
        {        
            [stepperBG setImage:[UIImage imageNamed:@"StepperPlusDown.png"]];

            tempo = tempoRange(tempo + (10 - (tempo % 10)));
        }
        else
        {
            [stepperBG setImage:[UIImage imageNamed:@"StepperMinusDown.png"]];
            if (tempo % 10 == 0)
                tempo = tempoRange(tempo - 10);
            else
                tempo = tempoRange(tempo - (tempo % 10));
        }
        
        
        [tempoLabel setText:[NSString stringWithFormat:@"%u BPM", tempo]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [stepperBG setImage:[UIImage imageNamed:@"StepperRolls.png"]];
    if (timeElapsed < 0.5 && [myTouch locationInView:self].x >= ([self frame].size.width / 2))
    {
        tempo = tempoRange(tempo + 1);
        [tempoLabel setText:[NSString stringWithFormat:@"%u BPM", tempo]];
    }
    else if (timeElapsed < 0.5 && [myTouch locationInView:self].x < ([self frame].size.width / 2))
    {
        tempo = tempoRange(tempo - 1);
        [tempoLabel setText:[NSString stringWithFormat:@"%u BPM", tempo]];
    }
    [timer invalidate];
    timeElapsed = 0;
    [self.delegate valueChanged];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
