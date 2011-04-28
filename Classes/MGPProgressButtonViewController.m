//
//  MGPProgressButtonViewController.m
//  MGPProgressButton
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software LLC. All rights reserved.
//

#import "MGPProgressButtonViewController.h"
#import "MGPProgressButton.h"

static void const * testContext = &testContext;

@interface MGPProgressButtonViewController ()

@property (nonatomic, retain) NSTimer *progressTimer;
- (void) stopProgress;

@end

@implementation MGPProgressButtonViewController

@synthesize progressTimer;
@synthesize progressButton;
@synthesize buttonState;

- (void)dealloc 
{
    self.progressTimer = nil;
    self.progressButton = nil;
    self.buttonState = nil;
    [super dealloc];
}

- (void) viewDidLoad
{
    [self.progressButton addObserver:self forKeyPath:@"buttonState" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:&testContext];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == testContext)
    {
        if ([keyPath isEqualToString:@"buttonState"])
        {
            self.buttonState.text = self.progressButton.buttonState == ProgressButtonStatePlaying ? @"Playing" : self.progressButton.buttonState == ProgressButtonStatePaused ? @"Paused" : self.progressButton.buttonState == ProgressButtonStateRotating ? @"Rotating" : @"Unknown";
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction) startProgress
{
    if (!self.progressTimer) 
    {
        self.progressButton.progress = 0;
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.5
                                                          target:self
                                                        selector:@selector(incrementProgress:) 
                                                        userInfo:nil
                                                         repeats:YES];
    }
    else
    {
        [self stopProgress];
    }
}

- (void) stopProgress
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (IBAction) playingState
{
    self.progressButton.buttonState = ProgressButtonStatePlaying;
    [self startProgress];
}

- (IBAction) pauseState
{
    [self stopProgress];
    self.progressButton.buttonState = ProgressButtonStatePaused;
}

- (IBAction) rotatingState
{
    [self stopProgress];
    self.progressButton.buttonState = ProgressButtonStateRotating;
}

- (void) incrementProgress:(NSTimer *)timer
{
    if (self.progressButton.progress >= 1)
    {
        [self stopProgress];
    }
    
    self.progressButton.progress += 0.02;
}

@end
