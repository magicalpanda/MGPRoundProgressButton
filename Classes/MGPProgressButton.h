//
//  MGPProgressButton.h
//  Freshpod
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    ProgressButtonStatePaused    = 1 << 0,
    ProgressButtonStatePlaying   = 1 << 1,
    ProgressButtonStateRotating  = 1 << 2
} ProgressButtonState;

@interface MGPProgressButton : UIControl {
@private

    CAShapeLayer *backgroundGroup_;
    CAShapeLayer *background_;
    CAShapeLayer *backgroundRing_;    
    CAShapeLayer *playPauseButton_;
    CAShapeLayer *playPauseButtonRing_;
    
    UIColor *progressColor_;
    CGFloat progress_;
//    CGFloat strokeWidth_;
    ProgressButtonState currentState_;

    NSUInteger spinCount_;
}

@property (nonatomic, retain) NSNumber *progressMaximum;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, retain) UIColor *progressColor;
@property (nonatomic, assign) ProgressButtonState buttonState;
@property (nonatomic, readonly) CAShapeLayer *progressRing;

- (IBAction) beginLoading;
- (IBAction) resetProgress;

- (void) setButtonState:(ProgressButtonState)newState animated:(BOOL)animated;
- (void) setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
