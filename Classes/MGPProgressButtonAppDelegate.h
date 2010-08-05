//
//  MGPProgressButtonAppDelegate.h
//  MGPProgressButton
//
//  Created by Saul Mora on 8/4/10.
//  Copyright 2010 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MGPProgressButtonViewController;

@interface MGPProgressButtonAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MGPProgressButtonViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MGPProgressButtonViewController *viewController;

@end

