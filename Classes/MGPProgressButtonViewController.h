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

}

@property (nonatomic, retain) IBOutlet MGPProgressButton *progressButton;
@property (nonatomic, retain) IBOutlet UILabel *buttonState;

- (IBAction) startProgress;
- (IBAction) rotatingState;
- (IBAction) pauseState;
- (IBAction) playingState;

@end

