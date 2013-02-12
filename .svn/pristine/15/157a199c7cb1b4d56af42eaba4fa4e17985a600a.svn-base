//
//  MMProgressHUDWindow.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUDWindow.h"

@implementation MMProgressHUDWindow

- (id)init{
    
    if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
        self.backgroundColor = [UIColor clearColor];
        self.windowExclusionClasses = [NSMutableSet set];
        
        [self.windowExclusionClasses addObject:self.class];
        
        //could also use introspection with objc_ and class_ methods to get full list of
        //  subclasses that could be possible here, but would this include user-classes?
        //   It's possible, so we won't be using that approach here.
        NSArray *windowClassStrings = @[@"_UIAlertNormalizingOverlayWindow",
                                       @"UIAutoRotatingWindow",
                                       @"UIClassicWindow",
                                       @"UIPrintPanelWindow",
                                       @"UIRemoteWindow",
                                       @"UISoftwareDimmingWindow",
                                       @"UIStatusBarAdornmentWindow",
                                       @"UIStatusBarWindow",
                                       @"UITextEffectsWindow",
                                       @"_UIFallbackPresentationWindow"];
        
        for (NSString *classString in windowClassStrings) {
            Class potentialWindowClass = NSClassFromString(classString);
            
            if (potentialWindowClass) {
                [self.windowExclusionClasses addObject:potentialWindowClass];
            }
        }
    }
    return self;
}

- (void)makeKeyAndVisible{
    MMHudLog(@"Making key");
    
    self.windowLevel = UIWindowLevelStatusBar;
    
    [super makeKeyAndVisible];
}

- (UIWindow *)oldWindow{
    _oldWindow = nil;
	
    NSMutableArray *windowCandidates = [NSMutableArray array];
    
    for(UIWindow *window in [[UIApplication sharedApplication] windows]){
        
        //this will only check if the given window class is exactly the same
        //  class as the class listed in the excluded class and will
        //  not check if the given window class is a _subclass_ of a class
        //  in the list of excluded classes
        if (![self.windowExclusionClasses containsObject:window.class]) {
            if ([window.screen isEqual:[UIScreen mainScreen]]) {
                [windowCandidates addObject:window];
            }
        }
    }
    
    MMHudLog(@"Window Candidates: %@", windowCandidates);
    
	UIResponder <UIApplicationDelegate> *appDelegate = [UIApplication sharedApplication].delegate;
	if([appDelegate respondsToSelector:@selector(window)]) {
		UIWindow *delegateWindow = appDelegate.window;
		self.oldWindow = delegateWindow;
	} else if([windowCandidates count] > 0){
		self.oldWindow = windowCandidates[0];
	} else {
		self.oldWindow = nil;
	}
	
    MMHudLog(@"Old Window: %@", _oldWindow);
    
    return _oldWindow;
}

- (void)resignKeyWindow{
    [super resignKeyWindow];
    [self.oldWindow makeKeyWindow];
    
    MMHudLog(@"Resign key ended");
}

- (void)dealloc{
    MMHudLog(@"dealloc");
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _oldWindow = nil;
    
}

@end

