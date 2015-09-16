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
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.windowLevel = UIWindowLevelStatusBar;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)makeKeyAndVisible {
    MMHudLog(@"Making key");
    
    [super makeKeyAndVisible];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
- (UIWindow *)oldWindow NS_EXTENSION_UNAVAILABLE_IOS("Not available in app extensions."){
    if (_oldWindow == nil) {
        self.oldWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    
    MMHudLog(@"Old Window: %@", _oldWindow);
    
    return _oldWindow;
}
#pragma clang diagnostic pop

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    
    NSString *reqSysVer = @"8.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL usesWindowTransformRotation = ([currSysVer compare:reqSysVer
                                                    options:NSNumericSearch] != NSOrderedAscending);
    
    if (usesWindowTransformRotation == NO) {
        [self orientRootViewControllerForOrientation:rootViewController.interfaceOrientation];
    }
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

