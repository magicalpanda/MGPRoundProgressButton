//
//  MGPProgressButtonViewController.h
//  MGPProgressButton
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGPProgressButton;

@interface MGPProgressButtonViewController : UIViewController {

    NSTimer *_progressTimer;
}

@property (nonatomic, retain) IBOutlet MGPProgressButton *progressButton;

- (IBAction) startProgress;
- (IBAction) rotatingState;
- (IBAction) pauseState;
- (IBAction) playingState;

@end

