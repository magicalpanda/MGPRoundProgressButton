//
//  MGPProgressButton.h
//  Freshpod
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGPProgressButton : UIControl {
    CGFloat progress_;
    CGFloat strokeWidth_;
    BOOL playing_;
}

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, retain) UIColor *progressColor;

- (IBAction) playPause;

@end
