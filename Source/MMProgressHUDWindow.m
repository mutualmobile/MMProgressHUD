//
//  MMProgressHUDWindow.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUDWindow.h"
#import "MMProgressHUDCommon.h"

@implementation MMProgressHUDWindow

- (instancetype)init {
    if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]])) {
        self.windowLevel = UIWindowLevelStatusBar;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)makeKeyAndVisible {
    MMHudLog(@"Making key");
    
    [super makeKeyAndVisible];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
- (UIWindow *)oldWindow {
    if (_oldWindow == nil) {
        if ([[[UIApplication sharedApplication] windows] count]) {
            self.oldWindow = [[UIApplication sharedApplication] windows][0];
        }
        else {
            self.oldWindow = nil;
        }
    }
    
    MMHudLog(@"Old Window: %@", _oldWindow);
    
    return _oldWindow;
}
#pragma clang diagnostic pop

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    
    [self orientRootViewControllerForOrientation:rootViewController.interfaceOrientation];
}

- (void)orientRootViewControllerForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGAffineTransform transform;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
        case UIInterfaceOrientationPortrait:
            transform = CGAffineTransformIdentity;
            break;
    }
    
    self.rootViewController.view.transform = transform;
}

- (void)dealloc {
    MMHudLog(@"dealloc");
}

@end

