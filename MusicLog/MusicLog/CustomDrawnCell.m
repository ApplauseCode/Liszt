//
//  CustomDrawnCell.m
//  TableViewPerformance
//
//  Created by Mugunth Kumar on 7/11/11.
//

#import "CustomDrawnCell.h"

@implementation CustomDrawnCell

static UIFont *tonicFont = nil;
static UIFont *octavesFont = nil;
static UIFont *rhythmFont = nil;
static UIFont *modeFont = nil;
static UIFont *speedFont = nil;
static UIImage *_backgroundImage = nil;
static NSString *octaveFinisher = nil;
static UIFont *octaveFinisherFont = nil;

- (void)isPiece:(BOOL)piece setTonic:(NSString *)tonic octaves:(NSString *)octaves rhythm:(NSString *)rhythm mode:(NSString *)mode speed:(NSString *)speed
{
    if (_tonicLabel != tonic) {
        _tonicLabel = tonic;        
    }
    
    if (_octavesLabel != octaves) {
        _octavesLabel = octaves;
    }

    if (_rhythmLabel != rhythm) {
        _rhythmLabel = rhythm;
    }
    
    if (_modeLabel != mode) {
        _modeLabel = mode;
    }
    
    if (_speedLabel != [NSString stringWithFormat:@"%@ BPM", speed]) {
        _speedLabel = [NSString stringWithFormat:@"%@ BPM", speed];
    }
    
    isPiece = piece;
    [self setNeedsDisplay];
}

+(void) initialize
{
    _backgroundImage = [UIImage imageNamed:@"ScalesCellBG.png"];
    tonicFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:20];
    octavesFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:14];
    rhythmFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:14];
    modeFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:20];
    speedFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:14];
    
    octaveFinisher = @"8ve's";
    octaveFinisherFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:12];
}

+(void) dealloc
{
    [super dealloc];
}

-(void) drawContentView:(CGRect)r
{    
//    static UIColor *tonicColor;    
//    tonicColor = [UIColor darkTextColor];
//    static UIColor *subTitleColor;    
//    subTitleColor = [UIColor darkGrayColor];
//    static UIColor *timeTitleColor;    
//    timeTitleColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:0.7];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    if(self.highlighted || self.selected)
//	{
//		CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
//		CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
//		CGContextSetFillColorWithColor(context, titleColor.CGColor);					
//	}
//	else
//	{
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
//    CGContextSetFillColorWithColor(context, CGColorCreate(CGColorSpaceCreateDeviceRGB(), <#const CGFloat *components#>));					
//	}
    
//    [titleColor set];
    UIColor *blackColor = [UIColor blackColor];
    [blackColor set];
    
    if (!isPiece)
    {
        [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_tonicLabel drawAtPoint:CGPointMake(80, 7) 
                        forWidth:200 
                        withFont:tonicFont 
                        fontSize:20 
                   lineBreakMode:UILineBreakModeTailTruncation 
              baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        //    [subTitleColor set];
        [_speedLabel drawAtPoint:CGPointMake(80, 27) 
                        forWidth:200 
                        withFont:speedFont 
                        fontSize:14 
                   lineBreakMode:UILineBreakModeTailTruncation 
              baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        //    [timeTitleColor set];
        [_rhythmLabel drawAtPoint:CGPointMake(175, 27) 
                         forWidth:62 
                         withFont:rhythmFont 
                         fontSize:14 
                    lineBreakMode:UILineBreakModeTailTruncation 
               baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        [_modeLabel drawAtPoint:CGPointMake(175, 7)
                       forWidth:135
                       withFont:modeFont
                       fontSize:20
                  lineBreakMode:UILineBreakModeTailTruncation
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
        
        NSInteger octavesXCoord = 185 + [_rhythmLabel sizeWithFont:rhythmFont].width + 3;
        
        NSInteger octavesFinisherXCoord = octavesXCoord + [_octavesLabel sizeWithFont:octavesFont].width + 2;
        
        [octaveFinisher drawAtPoint:CGPointMake(octavesFinisherXCoord, 29)
                           forWidth:40
                           withFont:octaveFinisherFont
                           fontSize:12
                      lineBreakMode:UILineBreakModeTailTruncation
                 baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    }
    else
    {
        [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_tonicLabel drawAtPoint:CGPointMake(35, 7) 
                        forWidth:(175 - 35) 
                        withFont:tonicFont 
                        fontSize:20 
                   lineBreakMode:UILineBreakModeTailTruncation 
              baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        //    [subTitleColor set];
        [_speedLabel drawAtPoint:CGPointMake(35, 27) 
                        forWidth:(175 - 35) 
                        withFont:speedFont 
                        fontSize:14 
                   lineBreakMode:UILineBreakModeTailTruncation 
              baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        //    [timeTitleColor set];
        [_rhythmLabel drawAtPoint:CGPointMake(190, 27) 
                         forWidth:(320 - 35 - 175)
                         withFont:rhythmFont 
                         fontSize:14 
                    lineBreakMode:UILineBreakModeTailTruncation 
               baselineAdjustment:UIBaselineAdjustmentAlignCenters];    
        
        [_modeLabel drawAtPoint:CGPointMake(190, 7)
                       forWidth:(320 - 35 - 175)
                       withFont:modeFont
                       fontSize:20
                  lineBreakMode:UILineBreakModeTailTruncation
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
        
        NSInteger octavesXCoord = 185 + [_rhythmLabel sizeWithFont:rhythmFont].width + 3;
        
        [_octavesLabel drawAtPoint:CGPointMake(octavesXCoord , 27)
                          forWidth:60
                          withFont:octavesFont
                          fontSize:14
                     lineBreakMode:UILineBreakModeTailTruncation
                baselineAdjustment:UIBaselineAdjustmentAlignCenters];
    }
    

}

@end
