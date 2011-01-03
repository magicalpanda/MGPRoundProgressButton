//
//  MGPProgressButton.m
//  Freshpod
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software. All rights reserved.
//

#import "MGPProgressButton.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//TODO: Make this calculations based on the framesize
#define kBackgroundGroupPadding 6.

#define kProgressPathStroke 4.8
#define kProgressRingPadding 10.5

#define kBackgroundRingStroke .7
#define kBackgroundRingPadding 7.5

#define kPlayControlRingPadding 8.
#define kPlayControlRingStroke 1.8
#define kPlayButtonPadding 17.5

#define kProgressRingSpinTimeInterval 1.


CGFloat degreesToRadians(CGFloat degrees) 
{   
    return M_PI * degrees / 180.0;
}

CGMutablePathRef progressPath(CGRect frame, CGFloat padding, CGFloat progress)
{
    CGFloat borderSize = fmin(frame.size.width, frame.size.height);
    CGFloat radius = borderSize/2 - padding;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat startAngle = - M_PI_2;
    CGPathAddArc(path, NULL, frame.size.width/2, frame.size.height/2, radius, startAngle, progress * 2 * M_PI + startAngle, NO);
    return path;
}

CGMutablePathRef circlePath(CGRect frame, CGFloat padding)
{
    CGFloat borderSize = fmin(frame.size.width, frame.size.height);
    CGFloat radius = borderSize/2 - padding;
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat x = fabs(center.x - radius);
    CGFloat y = fabs(center.y - radius);
    CGPathAddEllipseInRect(path, NULL, CGRectMake(x, y, radius * 2, radius * 2));
    return path;
}

CGMutablePathRef playButtonPath(CGRect frame)
{
//    CGFloat borderSize = fmin(frame.size.width, frame.size.height);
    
    CGFloat startX =  frame.origin.x;
    CGFloat startY =  frame.origin.y;
    CGFloat buttonHeight = frame.size.height;
    CGFloat buttonWidth = frame.size.width;
    
    CGPoint leftHalf[] = { 
        CGPointMake(startX, startY),
        CGPointMake(startX + buttonWidth/2, startY + buttonHeight * 1/4),
        CGPointMake(startX + buttonWidth/2, startY + buttonHeight * 3/4),
        CGPointMake(startX, startY + buttonHeight),
        CGPointMake(startX, startY),        
    };
    
    CGPoint rightHalf[] = {
        CGPointMake(startX + buttonWidth/2, startY +  buttonHeight * 1/4),
        CGPointMake(startX + buttonWidth, startY + buttonHeight/2),
        CGPointMake(startX + buttonWidth/2, startY + buttonHeight * 3/4),
        CGPointMake(startX + buttonWidth/2, startY + buttonHeight * 1/4),        
    };
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines(path, NULL, leftHalf, 5);
    CGPathAddLines(path, NULL, rightHalf, 4);
    
    return path;
}

CGMutablePathRef pauseButtonPath(CGRect frame)
{
    CGFloat startX = frame.origin.x;
    CGFloat startY = frame.origin.y;
    
    CGFloat rectHeight = frame.size.height;
    CGFloat rectWidth = frame.size.width;
    
    CGFloat barWidth = rectWidth/3;
//    CGFloat kerning = frame.size.width/3;
    
    CGPoint leftBar[] = {
        CGPointMake(startX, startY), CGPointMake(startX + barWidth, startY),
        CGPointMake(startX + barWidth, startY + rectHeight), CGPointMake(startX, startY + rectHeight), 
        CGPointMake(startX, startY)
    };
    CGPoint rightBar[] = {
        CGPointMake(startX + rectWidth - barWidth, startY), 
        CGPointMake(startX + rectWidth, startY),
        CGPointMake(startX + rectWidth, startY + rectHeight),
        CGPointMake(startX + rectWidth - barWidth, startY + rectHeight),
        CGPointMake(startX + rectWidth - barWidth, startY)
    };
    
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathAddLines(path, NULL, leftBar, 5);
    CGPathAddLines(path, NULL, rightBar, 5);
  
    return path;
}

@implementation MGPProgressButton

@synthesize progressMaximum = progressMaximum_;
@synthesize progress = progress_;
@synthesize progressColor = progressColor_;
@synthesize progressRing = progressRing_;
@synthesize buttonState = currentState_;

- (void) dealloc
{
    [progressMaximum_ release], progressMaximum_ = nil;
    [backgroundGroup_ release], backgroundGroup_ = nil;
    [backgroundRing_ release], backgroundRing_ = nil;
    [background_ release], background_ = nil;
    [progressRing_ release], progressRing_ = nil;
    [playPauseButton_ release], playPauseButton_ = nil;
    [playPauseButtonRing_ release], playPauseButtonRing_ = nil;
    [super dealloc];
}

- (CGFloat) radialProgress
{
    return degreesToRadians( self.progress / 360.0 );
}

- (UIColor *) progressColor
{
    return progressColor_ ?: [UIColor colorWithRed:210./255. green:210./255. blue:210./255. alpha:1.];
}

- (void) setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    CALayer *mainLayer = self.layer;

    backgroundGroup_ = [[CAShapeLayer layer] retain];
    backgroundGroup_.frame = self.bounds;
    
    background_ = [[CAShapeLayer layer] retain];
    background_.opacity = .25;
    background_.fillColor = [UIColor blackColor].CGColor;
    background_.path = circlePath(self.bounds, kBackgroundGroupPadding);
    [backgroundGroup_ addSublayer:background_];

    backgroundRing_ = [[CAShapeLayer layer] retain];
    backgroundRing_.frame = self.bounds;
    backgroundRing_.path = circlePath(self.bounds, kBackgroundRingPadding);
    backgroundRing_.fillColor = nil;
    backgroundRing_.lineWidth = kBackgroundRingStroke;
    backgroundRing_.strokeColor = [UIColor whiteColor].CGColor;
    [backgroundGroup_ addSublayer:backgroundRing_];
    
    [mainLayer addSublayer:backgroundGroup_];

    playPauseButton_ = [[CAShapeLayer layer] retain];
    playPauseButton_.frame = self.bounds;
    playPauseButton_.masksToBounds = YES;
    playPauseButton_.path = playButtonPath(CGRectInset(self.bounds, kPlayButtonPadding, kPlayButtonPadding));
    playPauseButton_.strokeColor = [UIColor whiteColor].CGColor;
    playPauseButton_.fillColor = [UIColor whiteColor].CGColor;
    [mainLayer addSublayer:playPauseButton_];
    
    playPauseButtonRing_ = [[CAShapeLayer layer] retain];
    playPauseButtonRing_.frame = self.bounds;
    playPauseButtonRing_.masksToBounds = YES;
    playPauseButtonRing_.path = circlePath(self.bounds, kPlayControlRingPadding);
    playPauseButtonRing_.fillColor = nil;
    playPauseButtonRing_.strokeColor = [UIColor whiteColor].CGColor;
    playPauseButtonRing_.lineWidth = kPlayControlRingStroke;
    [mainLayer addSublayer:playPauseButtonRing_];

    mainLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    progress_ = 0;
    self.buttonState = ProgressButtonStatePaused;
    
    [self addTarget:self action:@selector(beginLoading) forControlEvents:UIControlEventTouchUpInside];    
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

- (NSNumber *) progressMaximum
{
    if (progressMaximum_ == nil) 
    {
        self.progressMaximum = [NSNumber numberWithInt:1];
    }
    return progressMaximum_;
}

- (void) setProgress:(CGFloat)progress
{
    if (0 < progress) 
    {
        if (progress < [self.progressMaximum doubleValue]) 
        {
            self.buttonState = ProgressButtonStatePlaying;
            progress_ = progress;
            self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, progress_ / [self.progressMaximum doubleValue]);
            [self.progressRing setNeedsDisplay];
        }
        else //reached mac progress
        {
            [self setButtonState:ProgressButtonStatePaused];
//            [self setIsPlaying:NO];
            [self resetProgress];
        }
    }
    else if (progress == 0)
    {
        progress_ = 0;
    }
}

- (CAShapeLayer *) progressRing
{
    if (progressRing_ == nil) 
    {
        progressRing_ = [[CAShapeLayer layer] retain];
        progressRing_.opacity = .75;
        progressRing_.frame = backgroundGroup_.bounds;
        progressRing_.fillColor = nil;
        progressRing_.strokeColor = self.progressColor.CGColor;
        progressRing_.lineWidth = kProgressPathStroke;
        [backgroundGroup_ addSublayer:progressRing_];
    }
    return progressRing_;
}

- (void) resetProgress
{
    [self setProgress:0];
}

- (void) rotateFirstHalf
{
    [self.progressRing removeAllAnimations];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D startRotation = CATransform3DMakeRotation(0, 0, 0, 1.);
    CATransform3D endRotation = CATransform3DMakeRotation(degreesToRadians(180.), 0, 0, 1.);
    
    rotate.fromValue = [NSValue valueWithCATransform3D:startRotation];
    rotate.toValue = [NSValue valueWithCATransform3D:endRotation];
    rotate.delegate = self;
    rotate.duration = kProgressRingSpinTimeInterval / 2;
    
    [self.progressRing addAnimation:rotate forKey:@"firstHalf"];    
}

- (void) rotateSecondHalf
{
    [self.progressRing removeAllAnimations];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D startRotation = CATransform3DMakeRotation(degreesToRadians(180.), 0, 0, 1.);
    CATransform3D endRotation = CATransform3DMakeRotation(degreesToRadians(360.), 0, 0, 1.);
    
    rotate.fromValue = [NSValue valueWithCATransform3D:startRotation];
    rotate.toValue = [NSValue valueWithCATransform3D:endRotation];
    rotate.duration = kProgressRingSpinTimeInterval / 2;
    rotate.delegate = self;
    
    [self.progressRing addAnimation:rotate forKey:@"secondHalf"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    if (!finished) return;

    spinCount_++ % 2 ? [self rotateFirstHalf] : [self rotateSecondHalf];
}

- (IBAction) beginLoading;
{
    if (self.buttonState == ProgressButtonStatePaused) 
    {
        [self setButtonState:ProgressButtonStateRotating];
    }
    else if (self.buttonState == ProgressButtonStatePlaying || self.buttonState == ProgressButtonStateRotating)
    {
        self.buttonState = ProgressButtonStatePaused;
    }

#ifdef DEBUG
    if (self.progress == 0 || self.buttonState == ProgressButtonStateRotating) 
    {
        [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(playbackStarted) userInfo:nil repeats:NO];
    }
#endif
}

- (void) playbackStarted
{
    [self.progressRing removeAllAnimations];
    currentState_ = ProgressButtonStatePlaying;
    
    self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, 0);
    self.progressRing.transform = CATransform3DIdentity;
}

- (void) setButtonState:(ProgressButtonState)mode
{
    if (mode == self.buttonState) return;
    
    [backgroundGroup_ removeAllAnimations];
    
    CATransform3D scaleTransform = mode == ProgressButtonStatePaused ? 
            CATransform3DIdentity :
            CATransform3DIsIdentity(backgroundGroup_.transform) ? CATransform3DScale(backgroundGroup_.transform, 1.3, 1.3, 1) : backgroundGroup_.transform;

    backgroundGroup_.transform = scaleTransform;
    
    [backgroundGroup_ setNeedsDisplay];
    
    CGRect buttonFrame = CGRectInset(self.bounds, kPlayButtonPadding, kPlayButtonPadding);
    
    BOOL fromPlayButton = self.buttonState == ProgressButtonStatePaused;
    BOOL toPlayButton = mode != ProgressButtonStatePlaying && mode != ProgressButtonStateRotating;
    
    if (fromPlayButton != toPlayButton) 
    {
        CGMutablePathRef fromPath = fromPlayButton ? playButtonPath(buttonFrame) : pauseButtonPath(buttonFrame);
        CGMutablePathRef toPath = toPlayButton ? playButtonPath(buttonFrame) : pauseButtonPath(buttonFrame);
        
        [playPauseButton_ setPath:toPath];
        
        [playPauseButton_ removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (id)toPath;
        animation.fromValue = (id)fromPath;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion =  NO;
        
        [playPauseButton_ addAnimation:animation forKey:@"playControlToggle"];
    }
    
    if (mode == ProgressButtonStateRotating && self.progress == 0)  
    {
        spinCount_ = 0;
        self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, .3);
        [self rotateFirstHalf];
    }
    else 
    {
        self.progressRing.path = nil;
        [self.progressRing removeAllAnimations];
    }
    if (mode == ProgressButtonStatePlaying) 
    {
        [self playbackStarted];
    }

    currentState_ = mode;
}

@end
