//
//  MMProgressHUDViewController.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUDViewController.h"
#import "MMProgressHUDWindow.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDCommon.h"


#define suppressDeprecation(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


@implementation MMProgressHUDViewController

- (void)setView:(UIView *)view {
    [super setView:view];
    
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    #ifdef __IPHONE_7_0
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    /** this line is important. this tells the view controller to not resize 
     the view to display the status bar -- unless we're on iOS 7 -- in 
     which case it's deprecated and does nothing */
    [self setWantsFullScreenLayout:YES];
        #endif
    #endif
#endif
    
}

- (BOOL)oldRootViewControllerShouldRotateToOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    BOOL shouldRotateToOrientation = NO;
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    suppressDeprecation(
        if ([[self superclass] instancesRespondToSelector:@selector(presentedViewController)] &&
            ([rootViewController presentedViewController] != nil)) {
            MMHudLog(@"Presented view controller: %@", rootViewController.presentedViewController);
            shouldRotateToOrientation = [rootViewController.presentedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
        
        if ((shouldRotateToOrientation == NO) &&
            (rootViewController != nil)) {
            
            shouldRotateToOrientation = [rootViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
        else if (rootViewController == nil) {
            MMHudWLog(@"Root view controller for your application cannot be found! Defaulting to liberal rotation handling for your device!");
            
            shouldRotateToOrientation = [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
    );
    
    return shouldRotateToOrientation;
}

/** The rotation callbacks for this view controller will never get fired on iOS <5.0. This must be related to creating a view controller in a new window besides the default keyWindow. Since this is the case, the manual method of animating the rotating the view's transform is used via notification observers added in setView: above.
 
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if ([self.view.window isKindOfClass:[MMProgressHUDWindow class]]) {
        return [self oldRootViewControllerShouldRotateToOrientation:toInterfaceOrientation];;
    }
    else {
        return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    
    if ([win isKindOfClass:[MMProgressHUDWindow class]] &&
        [rootViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [rootViewController supportedInterfaceOrientations];
    }
    else {
        MMHudWLog(@"Root view controller for your application cannot be found! Defaulting to liberal rotation handling for your device!");
    }
    
    return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
    UIViewController *rootViewController = win.oldWindow.rootViewController;
    
    if ([win isKindOfClass:[MMProgressHUDWindow class]] &&
        [rootViewController respondsToSelector:@selector(shouldAutorotate)]) {
        
        return [rootViewController shouldAutorotate];
    }
    else {
        MMHudWLog(@"Root view controller for your application cannot be found! Defaulting to liberal rotation handling for your device!");
    }
    
    return [super shouldAutorotate];
}

- (void)dealloc {
    MMHudLog(@"dealloc");
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [[UIApplication sharedApplication] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden{
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

@end
