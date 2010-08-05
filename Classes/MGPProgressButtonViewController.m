//
//  MGPProgressButtonViewController.m
//  MGPProgressButton
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software LLC. All rights reserved.
//

#import "MGPProgressButtonViewController.h"
#import "MGPProgressButton.h"

@implementation MGPProgressButtonViewController

@synthesize progressButton;

- (void)dealloc 
{
    self.progressButton = nil;
    [super dealloc];
}

- (IBAction) startProgress
{
    self.progressButton.progress = 0;
    _progressTimer = [[NSTimer scheduledTimerWithTimeInterval:.5
                                                      target:self
                                                    selector:@selector(incrementProgress:) 
                                                    userInfo:nil
                                                     repeats:YES] retain];
}

- (void) incrementProgress:(NSTimer *)timer
{
    if (self.progressButton.progress >= 1)
    {
        [_progressTimer invalidate];
        [_progressTimer release];
    }
    
    self.progressButton.progress += 0.02;
}

@end
