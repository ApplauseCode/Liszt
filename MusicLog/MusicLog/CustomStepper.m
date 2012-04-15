//
//  CustomStepper.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/11/11.
//  Copyright (c) 2011 __Applause Code__. All rights reserved.
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
@synthesize canBeNone;

- (id)initWithPoint:(CGPoint)point label:(UILabel *)label andCanBeNone:(BOOL)_canBeNone
{
    self = [self initWithFrame:CGRectMake(point.x, point.y, 109.0, 62.0)];
    canBeNone = _canBeNone;
    tempoLabel = label;
    stepperBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"StepperRolls.png"]];
    [stepperBG setFrame:CGRectMake(0,0,109, 62)];
    [self addSubview:stepperBG];
    UIFont *caslon = [UIFont fontWithName:@"ACaslonPro-Regular" size:20];
    [tempoLabel setFont:caslon];
    [tempoLabel setTextColor:[UIColor yellowTextColor]];
    if (canBeNone)
        tempo = 0;
    else
        tempo = 80;
    tempoLabel.text = tempo == 0 ? @"NONE" : [NSString stringWithFormat:@"%u BPM", tempo];
    //[tempoLabel setText:[NSString stringWithFormat:@"%u BPM", tempo]];
    
    return self;
}

- (void)setTempo:(NSUInteger)_tempo
{
    tempo = _tempo;
    tempoLabel.text = tempo == 0 ? @"NONE" : [NSString stringWithFormat:@"%u BPM", tempo];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    myTouch = [touches anyObject];
    if ([myTouch locationInView:self].x >= ([self frame].size.width / 2))
        [stepperBG setImage:[UIImage imageNamed:@"StepperPlusDown.png"]];
    else
        [stepperBG setImage:[UIImage imageNamed:@"StepperMinusDown.png"]];

    timer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    timeElapsed += [timer timeInterval];
    if (timeElapsed >= 0.35)
    {    
        if ([myTouch locationInView:self].x >= ([self frame].size.width / 2))
        {        
            [stepperBG setImage:[UIImage imageNamed:@"StepperPlusDown.png"]];

            if (tempo == 0 && canBeNone)
                tempo = 30;
            else
                tempo = tempoRange(tempo + (10 - (tempo % 10)));
        }
        else
        {
            [stepperBG setImage:[UIImage imageNamed:@"StepperMinusDown.png"]];

            if (tempo == 30 && canBeNone)
                tempo = 0;
            else
            {        
                if (tempo % 10 == 0 && tempo != 0)
                    tempo = tempoRange(tempo - 10);
                else if (tempo != 0)
                    tempo = tempoRange(tempo - (tempo % 10));
            }
        }
        
        
        tempoLabel.text = tempo == 0 ? @"NONE" : [NSString stringWithFormat:@"%u BPM", tempo];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [stepperBG setImage:[UIImage imageNamed:@"StepperRolls.png"]];
    if (timeElapsed < 0.5 && [myTouch locationInView:self].x >= ([self frame].size.width / 2))
    {
        if (tempo == 0 && canBeNone)
            tempo = 30;
        else
            tempo = tempoRange(tempo + 1);
        tempoLabel.text = tempo == 0 ? @"NONE" : [NSString stringWithFormat:@"%u BPM", tempo];
    }
    else if (timeElapsed < 0.5 && [myTouch locationInView:self].x < ([self frame].size.width / 2))
    {
        if (tempo == 30 && canBeNone)
            tempo = 0;
        else if (tempo != 0)
            tempo = tempoRange(tempo - 1);
        tempoLabel.text = tempo == 0 ? @"NONE" : [NSString stringWithFormat:@"%u BPM", tempo];
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
