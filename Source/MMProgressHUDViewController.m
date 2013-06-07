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

@implementation MMProgressHUDViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

- (void)setView:(UIView *)view{
    [super setView:view];
    
    //this line is important. this tells the view controller to not resize
    //  the view to display the status bar.
    [self setWantsFullScreenLayout:YES];
    
    if (![[UIImage class] instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
        // <iOS 5.0
        //hacks ahoy!
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotationNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        UIInterfaceOrientation orientation = self.interfaceOrientation;
        
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                self.view.transform = CGAffineTransformIdentity;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.view.transform = CGAffineTransformMakeRotation(M_PI);
                break;
        }
    }
}

/* The rotation callbacks for this view controller will never get fired on iOS <5.0. This must be related to creating a view controller in a new window besides the default keyWindow. Since this is the case, the manual method of animating the rotating the view's transform is used via notification observers added in setView: above.
 
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    BOOL shouldRotateToOrientation = NO;
    
    if ([self.view.window class] == [MMProgressHUDWindow class]) {
        MMProgressHUDWindow *win = (MMProgressHUDWindow *)self.view.window;
        UIViewController *rootViewController = win.oldWindow.rootViewController;
        
        if ([[self superclass] instancesRespondToSelector:@selector(presentedViewController)] == YES) {
            if ([rootViewController presentedViewController]) {
                MMHudLog(@"Presented view controller: %@", rootViewController.presentedViewController);
                shouldRotateToOrientation = [rootViewController.presentedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
            }
        }
        
        if (!shouldRotateToOrientation && rootViewController) {
            shouldRotateToOrientation = [rootViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
        else if(!rootViewController){
            NSLog(@"%@ WARNING: root view controller for your application cannot be found! Defaulting to liberal rotation handling for your device!", NSStringFromClass([MMProgressHUD class]));
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                shouldRotateToOrientation = YES;
            }
            else{
                shouldRotateToOrientation = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ||
                                            (toInterfaceOrientation == UIInterfaceOrientationPortrait));
            }
        }
    }
    
    return shouldRotateToOrientation;
}

- (void)dealloc{
    MMHudLog(@"dealloc");
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - Rotation Handling (iOS 4.0)

/* This method is only used for iOS 4.0 rotation handling. iOS 5.0+ can support the view controller callbacks in a new window, so this method become unnecessary.  iOS 6 handles rotation even *more* differently, but this is not yet handled yet until this is actually utilized in an iOS 6 environment.
 
 */
- (void)handleRotationNotification:(NSNotification *)rotationNotification{
    //self.interfaceOrientation for some reason never changes here, must be related to rotation callbacks also not being called on <5.0
    [UIView
     animateWithDuration:0.40f
     animations:^{
         switch ([[UIDevice currentDevice] orientation]) {
             case UIDeviceOrientationLandscapeLeft:
                 self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                 break;
             case UIDeviceOrientationLandscapeRight:
                 self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                 break;
             case UIDeviceOrientationPortrait:
                 self.view.transform = CGAffineTransformIdentity;
                 break;
             case UIDeviceOrientationPortraitUpsideDown:
                 //only support upside down for iPads by default
                 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                     self.view.transform = CGAffineTransformMakeRotation(M_PI);
                 }
                 break;
             default:
                 //do nothing
                 break;
         }
     }];
}

@end
