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

#define kProgressRingSpinTimeInterval .65


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
    CGPathAddArc(path, NULL, frame.size.width/2, frame.size.height/2, radius, startAngle, progress * 2 * M_PI + startAngle, YES);
    return (CGMutablePathRef)[NSMakeCollectable(path) autorelease];
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
    return (CGMutablePathRef)[NSMakeCollectable(path) autorelease];
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
    
    return (CGMutablePathRef)[NSMakeCollectable(path) autorelease];
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
  
    return (CGMutablePathRef)[NSMakeCollectable(path) autorelease];
}

@interface MGPProgressButton ()

@property (nonatomic, retain) CAShapeLayer *background;
@property (nonatomic, retain) CAShapeLayer *backgroundGroup;
@property (nonatomic, retain) CAShapeLayer *backgroundRing;
@property (nonatomic, retain) CAShapeLayer *playPauseButton;
@property (nonatomic, retain) CAShapeLayer *playPauseButtonRing;
@property (nonatomic, retain) CAShapeLayer *progressRing;

@end

@implementation MGPProgressButton

@synthesize background = background_;
@synthesize backgroundGroup = backgroundGroup_;
@synthesize backgroundRing = backgroundRing_;
@synthesize playPauseButton = playPauseButton_;
@synthesize playPauseButtonRing = playPauseButtonRing_;

@synthesize progressMaximum = progressMaximum_;
@synthesize progress = progress_;
@synthesize progressColor = progressColor_;
@synthesize progressRing = progressRing_;
@synthesize buttonState = currentState_;

- (void) dealloc
{
    self.background = nil;
    self.backgroundGroup = nil;
    self.backgroundRing = nil;
    self.playPauseButton = nil;
    self.playPauseButtonRing = nil;
    
    self.progressMaximum = nil;
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

- (CAShapeLayer *) createBackgroundRing
{
    CAShapeLayer *backgroundRing = [CAShapeLayer layer];
    backgroundRing.frame = self.bounds;
    backgroundRing.path = circlePath(self.bounds, kBackgroundRingPadding);
    backgroundRing.fillColor = nil;
    backgroundRing.lineWidth = kBackgroundRingStroke;
    backgroundRing.strokeColor = [UIColor whiteColor].CGColor;
    return backgroundRing;
}

- (CAShapeLayer *) createBackground
{
    CAShapeLayer *background = [CAShapeLayer layer];
    background.opacity = .25;
    background.fillColor = [UIColor blackColor].CGColor;
    background.path = circlePath(self.bounds, kBackgroundGroupPadding);
    
//    background.actions = [NSDictionary dictionaryWithObject:[CABasicAnimation animationWithKeyPath:@"transform" forKey:<#(id)#>
    return background;
}

- (CAShapeLayer *) createPlayPauseButton
{
    CAShapeLayer *playPauseButton = [CAShapeLayer layer];
    playPauseButton.frame = self.bounds;
    playPauseButton.masksToBounds = YES;
    playPauseButton.path = playButtonPath(CGRectInset(self.bounds, kPlayButtonPadding, kPlayButtonPadding));
    playPauseButton.strokeColor = [UIColor whiteColor].CGColor;
    playPauseButton.fillColor = [UIColor whiteColor].CGColor;
    return playPauseButton;
}

- (CAShapeLayer *) createPlayPauseButtonRing
{
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring = [CAShapeLayer layer];
    ring.frame = self.bounds;
    ring.masksToBounds = YES;
    ring.path = circlePath(self.bounds, kPlayControlRingPadding);
    ring.fillColor = nil;
    ring.strokeColor = [UIColor whiteColor].CGColor;
    ring.lineWidth = kPlayControlRingStroke;   
    return ring;
}

- (CAShapeLayer *) createProgressRing
{
    CAShapeLayer *ring = [[CAShapeLayer layer] retain];
    ring.opacity = .75;
    ring.frame = self.backgroundGroup.bounds;
    ring.fillColor = nil;
    ring.lineWidth = kProgressPathStroke;

    return ring;
}

- (void) setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    CALayer *mainLayer = self.layer;
    mainLayer.backgroundColor = [UIColor clearColor].CGColor;

    self.backgroundGroup = [CAShapeLayer layer];
    self.backgroundGroup.frame = self.bounds;
    
    self.background = [self createBackground];
    [self.backgroundGroup addSublayer:self.background];

    self.backgroundRing = [self createBackgroundRing];
    [self.backgroundGroup addSublayer:self.backgroundRing];
    
    [mainLayer addSublayer:self.backgroundGroup];

    self.playPauseButton = [self createPlayPauseButton];
    [mainLayer addSublayer:self.playPauseButton];
    
    self.playPauseButtonRing = [self createPlayPauseButtonRing];
    [mainLayer addSublayer:self.playPauseButtonRing];
    
    progress_ = 0;
    progressMaximum_ = nil;
    self.buttonState = ProgressButtonStatePaused;
    
    [self addTarget:self action:@selector(handleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];    
}

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setupView];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
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
        CGFloat max = [self.progressMaximum floatValue];
        if (progress < max) 
        {
            self.buttonState = ProgressButtonStatePlaying;
            progress_ = progress;
            self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, progress_ / max);
            [self.progressRing setNeedsDisplay];
        }
        else //reached max progress
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

- (void) setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self setProgress:progress];
}

- (void) resetProgress
{
    [self setProgress:0];
}

- (void) beginRotatingShape:(CALayer *)shape
{
    [shape removeAllAnimations];
    CAKeyframeAnimation *rotate = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];

    rotate.values = [NSArray arrayWithObjects:
                    [NSNumber numberWithFloat:0 * M_PI], 
                     [NSNumber numberWithFloat:.5 * M_PI],
                     [NSNumber numberWithFloat:1 * M_PI],
                     nil];
    
    [rotate setKeyTimes:[NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:0], 
                         [NSNumber numberWithFloat:.5],
                         [NSNumber numberWithFloat:1], nil]];
    rotate.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],        // from keyframe 1 to keyframe 2
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear
                                  ], nil]; // from keyframe 2 to keyframe 3
    rotate.removedOnCompletion = NO;
    rotate.fillMode = kCAFillModeForwards;
    rotate.cumulative = YES;
    rotate.repeatCount = INT_MAX;

    rotate.duration = kProgressRingSpinTimeInterval;
    
    [shape addAnimation:rotate forKey:@"rotate"];    
}


- (IBAction) handleTouchUpInside:(id)sender;
{
    if (self.buttonState == ProgressButtonStatePaused) 
    {
        [self setButtonState:ProgressButtonStateRotating];
    }
    else if (self.buttonState == ProgressButtonStatePlaying || self.buttonState == ProgressButtonStateRotating)
    {
        self.buttonState = ProgressButtonStatePaused;
    }
    self.progressRing.strokeColor = self.progressColor.CGColor;
    
#ifdef DEBUG
    if (self.progress == 0 || self.buttonState == ProgressButtonStateRotating) 
    {
        [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(playbackStarted) userInfo:nil repeats:NO];
    }
#endif
}

- (void) cancelCurrentAnimations
{
    [self.backgroundGroup removeAllAnimations];
    [self.backgroundRing removeAllAnimations];
    [self.progressRing removeAllAnimations];
    [self.playPauseButton removeAllAnimations];
    [self.playPauseButtonRing removeAllAnimations];
}

- (void) transitionToRotatingStateAnimated:(BOOL)animated
{
    //disable other animations...
    [self cancelCurrentAnimations];
    
    // make play button into pause
    
    //make background larger
    CGFloat scale = 1.3;
    CATransform3D startingTransform = self.backgroundGroup.transform;
    CATransform3D scaleTransform = CATransform3DIsIdentity(startingTransform) ? 
                CATransform3DScale(startingTransform, scale, scale, 1) :
                startingTransform;

    self.backgroundGroup.transform = scaleTransform;
    
    //make progress ring spin
    if (self.progressRing == nil)
    {
        self.progressRing = [self createProgressRing];
        [self.backgroundGroup addSublayer:self.progressRing];
    }
    
    self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, 1 - .3);
    self.progressRing.strokeColor = self.progressColor.CGColor;
                            
    [self beginRotatingShape:self.progressRing];
}

- (void) animate:(CAShapeLayer *)layer fromShape:(CGPathRef)fromPath toShape:(CGPathRef)toPath
{
    [layer setPath:toPath];
    [layer removeAllAnimations];


    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.toValue = (id)toPath;
    if (!CGPathEqualToPath(toPath, fromPath))
    {
        animation.fromValue = (id)fromPath;
    }
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion =  NO;
    
    [layer addAnimation:animation forKey:@"playControlToggle"];
}

- (void) transitionToPlayingStateAnimated:(BOOL)animated
{
    [self cancelCurrentAnimations];
    
    //make progress ring small
    self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, 0);
    self.progressRing.transform = CATransform3DIdentity;

    CGFloat scale = 1.3;
    CATransform3D startingTransform = self.backgroundGroup.transform;

    CATransform3D scaleTransform = CATransform3DIsIdentity(startingTransform) ?  CATransform3DScale(startingTransform, scale, scale, 1) : startingTransform;
    
    self.backgroundGroup.transform = scaleTransform;

    
    //transition to pause button
    CGRect buttonFrame = CGRectInset(self.bounds, kPlayButtonPadding, kPlayButtonPadding);
    
    CGMutablePathRef fromPath = playButtonPath(buttonFrame);
    CGMutablePathRef toPath = pauseButtonPath(buttonFrame);
    
    [self animate:self.playPauseButton fromShape:fromPath toShape:toPath];
}

- (void) transitionToPausedStateAnimated:(BOOL)animated
{
    //make progress ring small
    self.progressRing.path = progressPath(self.bounds, kProgressRingPadding, 0);
    self.progressRing.transform = CATransform3DIdentity;
    self.backgroundGroup.transform = CATransform3DIdentity;
 
    //transition to play button
    CGRect buttonFrame = CGRectInset(self.bounds, kPlayButtonPadding, kPlayButtonPadding);
    
    CGMutablePathRef toPath = playButtonPath(buttonFrame);
    CGMutablePathRef fromPath = pauseButtonPath(buttonFrame);
    
    [self animate:self.playPauseButton fromShape:fromPath toShape:toPath];
}

- (void) setButtonState:(ProgressButtonState)newState
{
    [self setButtonState:newState animated:NO];
}

- (void) setButtonState:(ProgressButtonState)newState animated:(BOOL)animated;
{
    if (newState == self.buttonState) return;
    
    if (newState == ProgressButtonStatePaused)
    {
        [self transitionToPausedStateAnimated:animated];
    }
    else if (newState == ProgressButtonStatePlaying)
    {
        [self transitionToPlayingStateAnimated:animated];
    }
    else if (newState == ProgressButtonStateRotating)
    {
        [self transitionToRotatingStateAnimated:animated];
    }

    [self willChangeValueForKey:@"buttonState"];
    currentState_ = newState;
    [self didChangeValueForKey:@"buttonState"];
}

- (ProgressButtonState) nextState:(ProgressButtonState)currentState
{
    switch (currentState)
    {
        case ProgressButtonStatePaused:     return ProgressButtonStatePlaying;
        case ProgressButtonStatePlaying:    return ProgressButtonStatePaused;
        default:
        case ProgressButtonStateRotating:   return ProgressButtonStateRotating;
    }
}

@end
