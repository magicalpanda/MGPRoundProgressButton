//
//  MGPProgressButton.m
//  Freshpod
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software. All rights reserved.
//

#import "MGPProgressButton.h"

CGFloat degreesToRadians(CGFloat degrees) 
{   
    return M_PI * degrees / 180.0;
}

@implementation MGPProgressButton

@synthesize progress = progress_;
@synthesize progressColor = progressColor_;

- (CGFloat) radius
{
    CGFloat outerRadius = MIN(self.bounds.size.width, self.bounds.size.height);
    return (outerRadius - (2 * strokeWidth_)) / 2;
}

- (CGFloat) radialProgress
{
    return degreesToRadians( self.progress / 360.0 );
}

- (UIColor *) progressColor
{
    return progressColor_ ?: [UIColor colorWithRed:10./255. green:210./255. blue:10./255. alpha:1.];
}

- (void) setupView
{
    self.backgroundColor = [UIColor clearColor];
    progress_ = 0;
    strokeWidth_ = 10.;
    playing_ = NO;
    [self addTarget:self action:@selector(playPause) forControlEvents:UIControlEventTouchUpInside];    
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) 
    {
        [self setupView];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupView];
    }
    return self;
}

- (void) setProgress:(CGFloat)p
{
    if (0 <= p && p <= 1) 
    {
        progress_ = p;
        [self setNeedsDisplay];
    }
}

- (void) drawPlayButton:(CGPoint)center inContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(0, 1), .5);
    
    CGContextMoveToPoint(context, center.x - 10, center.y + 12);
    CGContextAddLineToPoint(context, center.x + 15, center.y);
    CGContextAddLineToPoint(context, center.x - 10, center.y - 12);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    CGContextClosePath(context);
}

- (void) drawPauseButton:(CGPoint)center inContext:(CGContextRef)context
{
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(0, 1), .5);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 8);
    CGPoint leftBar[2] = {
        CGPointMake(center.x - 6, center.y - 15), CGPointMake(center.x - 6, center.y + 15)
    };
    CGContextAddLines(context, leftBar, 2);
    CGContextStrokePath(context);
    
    CGPoint rightBar[2] = {
        CGPointMake(center.x + 6, center.y - 15), CGPointMake(center.x + 6, center.y + 15)
    };
    CGContextAddLines(context, rightBar, 2);
    CGContextStrokePath(context);

    CGContextRestoreGState(context);
    CGContextClosePath(context);    
}

- (void) drawRadialProgress:(CGPoint)center inContext:(CGContextRef)context
{
    if (progress_ > 0) 
    {
        CGContextBeginPath(context);

        CGFloat progressRadius = [self radius] - strokeWidth_/2;
        
        CGContextSetStrokeColorWithColor(context, self.progressColor.CGColor);
        CGContextSetLineWidth(context, strokeWidth_);
        CGFloat progress = self.progress * 2 * M_PI;
        CGFloat startOffset = degreesToRadians(-90);
        CGContextAddArc(context, center.x, center.y, progressRadius, startOffset, startOffset + progress, NO);
        CGContextStrokePath(context);
        
        CGContextClosePath(context);
    }    
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);

    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextBeginPath(context);
    CGContextSetGrayStrokeColor(context, .5, .5);

    CGContextSetLineWidth(context, 1.);
    CGContextAddArc(context, center.x, center.y, 23., 0, 2 * M_PI, YES);
    
    CGContextStrokePath(context);

//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.0,  // Start color
//        1.0, 1.0, 1.0, 0.5 }; // End color
//    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
//    
//    CGContextDrawRadialGradient(context, glossGradient, center, [self radius], center, [self radius] - strokeWidth_, kCGGradientDrawsAfterEndLocation);
    
    [self drawRadialProgress:center inContext:context];
    
    playing_ ? [self drawPlayButton:center inContext:context] : [self drawPauseButton:center inContext:context];
}

- (IBAction) playPause;
{
    playing_ = !playing_;
    [self setNeedsDisplay];
}

@end
