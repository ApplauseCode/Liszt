//
//  CustomStepper.m
//  MusicLog
//
//  Created by Kyle Rosenbluth on 9/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomStepper.h"

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
}
@end
@implementation CustomStepper

@synthesize tempo;

- (id)initWithPoint:(CGPoint)point andLabel:(UILabel *)label
{
    self = [self initWithFrame:CGRectMake(point.x, point.y, 92.0, 37.0)];
    tempoLabel = label;
    [self setBackgroundColor:[UIColor blueColor]];
    tempo = 80;
    [tempoLabel setText:[NSString stringWithFormat:@"%u bpm", tempo]];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    myTouch = [touches anyObject];

    timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    timeElapsed += [timer timeInterval];
    if (timeElapsed >= 0.5)
    {    
        if ([myTouch locationInView:self].x >= ([self frame].size.width / 2))
        {
            
            tempo = tempoRange(tempo + (10 - (tempo % 10)));
        }
        else
        {
            {
                if (tempo % 10 == 0)
                    tempo = tempoRange(tempo - 10);
                else
                    tempo = tempoRange(tempo - (tempo % 10));
            }
        }
        
        
        [tempoLabel setText:[NSString stringWithFormat:@"%u bpm", tempo]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (timeElapsed < 0.5 && [myTouch locationInView:self].x >= ([self frame].size.width / 2))
    {
        tempo = tempoRange(tempo + 1);
        [tempoLabel setText:[NSString stringWithFormat:@"%u bpm", tempo]];
    }
    else if (timeElapsed < 0.5 && [myTouch locationInView:self].x < ([self frame].size.width / 2))
    {
        tempo = tempoRange(tempo - 1);
        [tempoLabel setText:[NSString stringWithFormat:@"%u bpm", tempo]];
    }
    [timer invalidate];
    timeElapsed = 0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
