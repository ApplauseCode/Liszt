//
//  LisztCell.m
//  Liszt
//
//  Created by Jeffrey Rosenbluth on 3/11/12.
//  Copyright (c) 2012 Applause Code. All rights reserved.
//

#import "LisztCell.h"

#define kVerySmallFontSize 13
#define kLargeFontSize 18
#define kSmallFontSize 16

@interface LisztCellView : UIView
@end

@implementation LisztCellView

- (void)drawRect:(CGRect)r
{
	[(LisztCell *)[self superview] drawContentView:r];
}

@end

@implementation LisztCell

static UIFont *_defaultVerySmallFont = nil;
static UIFont *_defaultSmallFont = nil;
static UIFont *_defaultLargeFont = nil;
static UIImage *_backgroundImage = nil;
static NSString *_octaveFinisher = nil;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		contentView = [[LisztCellView alloc]initWithFrame:CGRectZero];
		contentView.opaque = YES;
		[self addSubview:contentView];
	}
	return self;
}

- (void) updateLabels:(id) thing
{
   //override in concrete classes
}

- (void)setFrame:(CGRect)f
{
	[super setFrame:f];
	CGRect b = [self bounds];
	b.size.height -= 0; // leave room for the seperator line
	[contentView setFrame:b];
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

+(void) initialize
{
    _backgroundImage = [UIImage imageNamed:@"ScalesCellBG.png"];
    _defaultVerySmallFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:kVerySmallFontSize];
    _defaultSmallFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:kSmallFontSize];
    _defaultLargeFont = [UIFont fontWithName:@"ACaslonPro-Regular" size:kLargeFontSize];
    _octaveFinisher = @"8ves";

}

- (UIFont *)defaultVerySmallFont {
    return _defaultVerySmallFont;
}

- (UIFont *)defaultSmallFont {
    return _defaultSmallFont;
}

- (UIFont *)defaultLargeFont {
    return _defaultLargeFont;
}

- (NSString *)octaveFinisher {
    return _octaveFinisher;
}

-(void) drawContentView:(CGRect)r
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    UIColor *blackColor = [UIColor blackColor];
    [blackColor set];
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
