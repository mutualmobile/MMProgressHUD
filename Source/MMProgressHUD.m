//
//  MMProgressHUD.m
//  MMProgressHUD
//
//  Created by Lars Anderson on 10/7/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MMProgressHUD.h"
#import "MMProgressHUDCommon.h"
#import "MMProgressHUD+Animations.h"

#import "MMProgressHUDWindow.h"
#import "MMProgressHUDViewController.h"

#import "MMProgressHUDOverlayView.h"
#import "MMVectorImage.h"

#import "MMLinearProgressView.h"
#import "MMRadialProgressView.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error MMProgressHUD uses APIs only available in iOS 5.0+
#endif

NSString * const MMProgressHUDDefaultConfirmationMessage = @"Cancel?";
NSString * const MMProgressHUDAnimationShow = @"mm-progress-hud-present-animation";
NSString * const MMProgressHUDAnimationDismiss = @"mm-progress-hud-dismiss-animation";
NSString * const MMProgressHUDAnimationWindowFadeOut = @"mm-progress-hud-window-fade-out";
NSString * const MMProgressHUDAnimationKeyShowAnimation = @"show";
NSString * const MMProgressHUDAnimationKeyDismissAnimation = @"dismiss";

NSUInteger const MMProgressHUDConfirmationPulseCount = 8;//Keep this number even

CGFloat const MMProgressHUDStandardDismissDelay = 0.75f;

CGSize const MMProgressHUDDefaultImageSize = {37.f, 37.f};

#pragma mark - MMProgressHUD
@interface MMProgressHUD () <MMHudDelegate>

@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) MMProgressHUDWindow *window;
@property (nonatomic, readwrite, getter = isVisible)  BOOL visible;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSArray *animationImages;
@property (nonatomic, strong) CAAnimation *queuedShowAnimation;
@property (nonatomic, strong) CAAnimation *queuedDismissAnimation;
@property (nonatomic, readwrite, strong) MMProgressHUDOverlayView *overlayView;
@property (nonatomic, strong) NSTimer *dismissDelayTimer;
@property (nonatomic, copy) NSString *tempStatus;
@property (nonatomic, strong) NSTimer *confirmationTimer;
@property (nonatomic, getter = isConfirmed) BOOL confirmed;
@property (nonatomic, assign) BOOL presentedAnimated;
@property (nonatomic, strong) MMProgressHUDViewController *presentationViewController;

@end

@implementation MMProgressHUD

#pragma mark - Class Methods
+ (instancetype)sharedHUD {
    static MMProgressHUD *__sharedHUD = nil;
    
    static dispatch_once_t mmSharedHUDOnceToken;
    dispatch_once(&mmSharedHUDOnceToken, ^{        
        __sharedHUD = [[MMProgressHUD alloc] init];
    });
    
    return __sharedHUD;
}

#pragma mark - Instance Presentation Methods
- (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status
                     confirmationMessage:(NSString *)confirmation
                             cancelBlock:(void (^)(void))cancelBlock
                                  images:(NSArray *)images {
    [self.hud setIndeterminate:NO];
    
    [self showWithTitle:title
                 status:status
    confirmationMessage:confirmation
            cancelBlock:cancelBlock
                 images:images];
}

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images {
    
    self.image = nil;
    self.animationImages = nil;
    
    if (images.count == 1) {
        self.image = images[0];
    }
    else if (images.count > 0) {
        self.animationImages = images;
    }
    
    self.cancelBlock = cancelBlock;
    self.title = title;
    self.status = status;
    
    if (confirmationMessage.length > 0) {
        self.confirmationMessage = confirmationMessage;
    }
    else {
        self.confirmationMessage = MMProgressHUDDefaultConfirmationMessage;
    }
    
    if ((self.isVisible == YES) &&
        (self.window != nil) &&
        ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] == nil)) {
        [self _updateHUDAnimated:YES withCompletion:nil];
    }
    else {
        [self show];
    }
}

- (void)dismissWithCompletionState:(MMProgressHUDCompletionState)completionState
                             title:(NSString *)title
                           status:(NSString *)status
                        afterDelay:(NSTimeInterval)delay {
    if (title) {
        self.title = title;
    }
    
    if (status) {
        self.status = status;
    }
    
    self.hud.completionState = completionState;
    
    if (self.isVisible) {
        [self _updateHUDAnimated:YES withCompletion:^(BOOL completed) {
            [self dismissAfterDelay:delay];
        }];
    }
}

- (void)updateProgress:(CGFloat)progress withStatus:(NSString *)status title:(NSString *)title{
    [self setProgress:progress];
    
    if (status != nil) {
        self.hud.messageText = status;
    }
    
    if (title != nil) {
        self.hud.titleText = title;
    }
    
    if (self.isVisible &&
        (self.window != nil)) {
        
        void(^animationCompletion)(BOOL completed) = ^(BOOL completed) {
            if (progress >= 1.f &&
                self.progressCompletion != nil) {
                double delayInSeconds = 0.33f;//allow enough time for progress to animate
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    if (self.progressCompletion) {
                        self.progressCompletion();
                    }
                });
            }
        };
        
        [self _updateHUDAnimated:YES
                 withCompletion:animationCompletion];
    }
    else {
        [self show];
    }
}

#pragma mark - Initializers
- (instancetype)init {
    if ( (self = [super initWithFrame:CGRectZero]) ) {
        self.hud = [[MMHud alloc] init];
        self.hud.delegate = self;

        UIColor *imageFill = [UIColor colorWithWhite:1.f alpha:1.f];
        self.errorImage = [MMVectorImage
                           vectorImageShapeOfType:MMVectorShapeTypeX
                           size:MMProgressHUDDefaultImageSize
                           fillColor:imageFill];
        self.successImage = [MMVectorImage
                             vectorImageShapeOfType:MMVectorShapeTypeCheck
                             size:MMProgressHUDDefaultImageSize
                             fillColor:imageFill];
        
        [self setAutoresizingMask:
         UIViewAutoresizingFlexibleHeight |
         UIViewAutoresizingFlexibleWidth];
    }
    
    return self;
}

- (void)dealloc {
    MMHudLog(@"dealloc");
    
    if (_window != nil) {
        [_window setHidden:YES];
    }
}

- (void)forceCleanup {
    //Do not invoke this method unless you are in a unit test environment
    if (self.window != nil) {
        [self.window setHidden:YES];
    }
    self.presentationViewController = nil;
    self.window.rootViewController = nil;
    self.window = nil;
}

#pragma mark - Passthrough Properties
- (void)setOverlayMode:(MMProgressHUDWindowOverlayMode)overlayMode {
    self.overlayView.overlayMode = overlayMode;
}

- (MMProgressHUDWindowOverlayMode)overlayMode {
    return self.overlayView.overlayMode;
}

- (void)setAnimationLoopDuration:(CGFloat)animationLoopDuration {
    self.hud.animationLoopDuration = animationLoopDuration;
}

- (CGFloat)animationLoopDuration {
    return self.hud.animationLoopDuration;
}

- (void)setProgress:(CGFloat)progress {
    [self.hud setProgress:progress animated:YES];
    
    self.hud.accessibilityValue = [NSString stringWithFormat:@"%i%%", (int)(progress/1.f*100)];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [NSString stringWithFormat:@"%@ %@", self.hud.accessibilityLabel, self.hud.accessibilityValue]);
}

- (CGFloat)progress {
    return self.hud.progress;
}

- (void)setProgressStyle:(MMProgressHUDProgressStyle)progressStyle{
    self.hud.progressStyle = progressStyle;
    
    switch (progressStyle) {
        case MMProgressHUDProgressStyleIndeterminate:
            self.hud.progressViewClass = nil;
            self.accessibilityTraits &= ~UIAccessibilityTraitUpdatesFrequently;
            break;
        case MMProgressHUDProgressStyleLinear:
            self.hud.progressViewClass = [MMLinearProgressView class];
            self.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
            break;
        case MMProgressHUDProgressStyleRadial:
            self.hud.progressViewClass = [MMRadialProgressView class];
            self.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
            break;
    }
}

- (MMProgressHUDProgressStyle)progressStyle{
    return self.hud.progressStyle;
}

- (void)setTitle:(NSString *)title {
    self.hud.titleText = title;
}

- (NSString *)title {
    return self.hud.titleText;
}

- (void)setStatus:(NSString *)status {
    self.hud.messageText = status;
}

- (NSString *)status {
    return self.hud.messageText;
}
    
- (void)setImage:(UIImage *)image{
    _image = image;
    [self.hud setImage:image];
}

#pragma mark - Property Overrides

- (void)setProgressViewClass:(Class)progressViewClass{
    self.hud.progressViewClass = progressViewClass;
}

- (Class)progressViewClass{
    return self.hud.progressViewClass;
}

- (MMProgressHUDOverlayView *)overlayView {
    if (_overlayView == nil) {
        _overlayView = [[MMProgressHUDOverlayView alloc] init];
        _overlayView.alpha = 0.f;
    }
    
    return _overlayView;
}

- (CGColorRef)glowColor {
    if (_glowColor == NULL) {
        CGColorRef redColor = CGColorRetain([UIColor redColor].CGColor);
        self.glowColor = redColor;
        CGColorRelease(redColor);
    }
    
    return _glowColor;
}

- (MMHud *)hud {
    if (_hud == nil) {
        _hud = [[MMHud alloc] init];
    }
    
    return _hud;
}

- (void)setProgressCompletion:(void (^)(void))progressCompletion {
    if (progressCompletion != nil) {
        __typeof(self) __weak weakSelf = self;
        _progressCompletion = ^(void) {
            progressCompletion();
            
            weakSelf.progressCompletion = nil;
        };
    }
    else {
        _progressCompletion = nil;
    }
}

- (void)setCancelBlock:(void (^)(void))cancelBlock {
    _cancelBlock = cancelBlock;
    
    if (cancelBlock != nil) {
        self.hud.accessibilityTraits |=
        (UIAccessibilityTraitAllowsDirectInteraction |
        UIAccessibilityTraitButton);
    }
    else {
        self.hud.accessibilityTraits &= ~(UIAccessibilityTraitAllowsDirectInteraction |
                                         UIAccessibilityTraitButton);
    }
}

#pragma mark - Builders
- (void)_buildHUDWindow {
    if (self.window == nil) {
        self.window = [[MMProgressHUDWindow alloc] init];
        
        if (self.presentationViewController == nil) {
            self.presentationViewController = [[MMProgressHUDViewController alloc] init];
            if (self.presentationViewController.view != self)
                [self.presentationViewController setView:self];
        }
        
        [self.window setRootViewController:self.presentationViewController];
        
        [self _buildOverlayViewForMode:self.overlayMode inView:self.window];
        [self.window setHidden:NO];
    }
}

- (void)_buildOverlayViewForMode:(MMProgressHUDWindowOverlayMode)overlayMode inView:(UIView *)view {
    
    self.overlayView.frame = view.bounds;
    self.overlayView.overlayMode = overlayMode;
    
    [view insertSubview:self.overlayView atIndex:0];
}

- (void)_buildHUD {
    [self setAutoresizingMask:
     UIViewAutoresizingFlexibleHeight | 
     UIViewAutoresizingFlexibleWidth];
    
    [self _buildHUDWindow];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    [tapToDismiss setNumberOfTapsRequired:1];
    [tapToDismiss setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tapToDismiss];
    
    self.hud.image = self.image;
    self.hud.animationImages = self.animationImages;
    
    self.hud.layer.transform = CATransform3DIdentity;
    
    [self.hud setNeedsUpdate:YES];
    
    [self.hud applyLayoutFrames];
    
    [self addSubview:self.hud];
}

#pragma mark - Layout
- (void)_updateMessageLabelsAnimated:(BOOL)animated {
    [self.hud updateTitle:self.title message:self.status animated:animated];
}

- (void)_updateHUDAnimated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completionBlock {
    MMHudLog(@"Updating %@ with completion...", NSStringFromClass(self.class));
    
    if (self.dismissDelayTimer != nil) {
        [self.dismissDelayTimer invalidate], self.dismissDelayTimer = nil;
    }
    
    if (animated) {
        [UIView
         animateWithDuration:0.1f
         delay:0.f
         options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             [self _updateHUD];
         }
         completion:completionBlock];
    }
    else {
        [self _updateHUD];
        
        if (completionBlock != nil) {
            completionBlock(YES);
        }
    }
}

- (void)_updateHUD {
    [self.hud updateLayoutFrames];
    
    [self.hud updateAnimated:YES withCompletion:nil];
    
    self.hud.center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
}

- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor {
    
    CGFloat hudHeight = CGRectGetHeight(self.hud.frame);
    
    CGPoint position;
    if (UIInterfaceOrientationIsPortrait([[self.window rootViewController] interfaceOrientation])) {
        
        CGFloat y = roundf(self.window.center.y + (anchor.y - 0.5f) * hudHeight);
        CGFloat x = roundf(self.window.center.x);
        
        position = CGPointMake(x, y);
    }
    else {
        CGFloat x = roundf(self.window.center.y);
        CGFloat y = roundf(self.window.center.x + (anchor.y - 0.5f) * hudHeight);
        
        position = CGPointMake(x, y);
    }
    
    return [self _antialiasedPositionPointForPoint:position forLayer:self.hud.layer];
}

#pragma mark - Presentation
- (void)show {
    if (self.dismissDelayTimer != nil) {
        [self.dismissDelayTimer invalidate], self.dismissDelayTimer = nil;
    }
    
    NSAssert([NSThread isMainThread], @"Show should be run on main thread!");
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self _buildHUD];
    
    self.presentedAnimated = YES;
    switch (self.presentationStyle) {
        case MMProgressHUDPresentationStyleDrop:
            [self _showWithDropAnimation];
            break;
        case MMProgressHUDPresentationStyleExpand:
            [self _showWithExpandAnimation];
            break;
        case MMProgressHUDPresentationStyleShrink:
            [self _showWithShrinkAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingLeft:
            [self _showWithSwingInAnimationFromLeft:YES];
            break;
        case MMProgressHUDPresentationStyleSwingRight:
            [self _showWithSwingInAnimationFromLeft:NO];
            break;
        case MMProgressHUDPresentationStyleBalloon:
            [self _showWithBalloonAnimation];
            break;
        case MMProgressHUDPresentationStyleFade:
            [self _showWithFadeAnimation];
            break;
        case MMProgressHUDPresentationStyleNone:
        default:{
            self.presentedAnimated = NO;
            
            CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
            
            self.hud.center = newCenter;
            self.hud.layer.transform = CATransform3DIdentity;
            self.hud.alpha = 1.f;
            self.overlayView.alpha = 1.0f;
            self.visible = YES;
            
        }
            break;
    }
    
    [CATransaction commit];
    
    CGFloat duration = (self.presentationStyle == MMProgressHUDPresentationStyleNone) ? 0.f : MMProgressHUDAnimateInDurationShort;
    
    [UIView
     animateWithDuration:duration
     delay:0.f
     options:UIViewAnimationOptionCurveEaseOut |
             UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.overlayView.alpha = 1.0f;
     }
     completion:^(BOOL completed) {
         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.hud.accessibilityLabel);
     }];
}

- (void)dismissAfterDelay:(NSTimeInterval)delay {
    if (self.visible == NO) {
        MMHudLog(@"Preventing delayed dismissal when already dismissed!");
        return;
    }
    [self.dismissDelayTimer invalidate];
    self.dismissDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
}

- (void)dismiss {
    if (self.visible == NO) {
        MMHudLog(@"Preventing dismissal when already dismissed!");
        return;
    }
    NSAssert([NSThread isMainThread], @"Dismiss method should be run on main thread!");
    
    MMHudLog(@"Dismissing...");
    
    switch (self.presentationStyle) {
        case MMProgressHUDPresentationStyleDrop:
            [self _dismissWithDropAnimation];
            break;
        case MMProgressHUDPresentationStyleExpand:
            [self _dismissWithExpandAnimation];
            break;
        case MMProgressHUDPresentationStyleShrink:
            [self _dismissWithShrinkAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingLeft:
            [self _dismissWithSwingLeftAnimation];
            break;
        case MMProgressHUDPresentationStyleSwingRight:
            [self _dismissWithSwingRightAnimation];
            break;
        case MMProgressHUDPresentationStyleBalloon:
            [self _dismissWithBalloonAnimation];
            break;
        case MMProgressHUDPresentationStyleFade:
            [self _dismissWithFadeAnimation];
            break;
        case MMProgressHUDPresentationStyleNone:
        default:
            self.hud.layer.opacity = 0.f;
            self.overlayView.layer.opacity = 0.f;
            
            [self removeFromSuperview];
            
            self.visible = NO;
            [self.window setHidden:YES];
            self.window = nil;
            break;
    }
    
    typeof(self) __weak weakSelf = self;
    if (!self.queuedDismissAnimation) {
        [self _fadeOutAndCleanUp];
    } else {
        void (^oldCompletion)(void) = [self.showAnimationCompletion copy];
        self.showAnimationCompletion = ^{
            [weakSelf _fadeOutAndCleanUp];
            if (oldCompletion)
                oldCompletion();
        };
    }
}

- (void)_fadeOutAndCleanUp
{
    NSTimeInterval duration = (self.presentationStyle == MMProgressHUDPresentationStyleNone) ? 0.0 : MMProgressHUDAnimateOutDurationLong;
    NSTimeInterval delay = (self.presentationStyle == MMProgressHUDPresentationStyleDrop) ? MMProgressHUDAnimateOutDurationShort : 0.0;
    
    [UIView
     animateWithDuration:duration
     delay:delay
     options:UIViewAnimationOptionCurveEaseIn |
     UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         self.overlayView.alpha = 0.f;
     }
     completion:^(BOOL finished) {
         
         self.image = nil;
         self.animationImages = nil;
         self.progress = 0.f;
         self.hud.completionState = MMProgressHUDCompletionStateNone;
         [self.presentationViewController removeFromParentViewController];
         [self removeFromSuperview];
         self.presentationViewController.view = nil;
         self.presentationViewController = nil;
         
         [self.window setHidden:YES], self.window = nil;
         
         self.cancelled = NO;
         
         UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
     }];
}

- (CGPoint)_antialiasedPositionPointForPoint:(CGPoint)oldCenter forLayer:(CALayer *)layer {
    CGPoint newCenter = oldCenter;
    
    CGSize viewSize = layer.bounds.size;
    CGPoint anchor = layer.anchorPoint;
    
    double intPart;
    CGFloat viewXRemainder = modf(viewSize.width/2,&intPart);
    CGFloat viewCenterXRemainder = modf(oldCenter.x/2, &intPart);
    
    if (anchor.x != 0.f && anchor.x != 1.f) {
        if (((viewXRemainder == 0) &&//if view width is even
            (viewCenterXRemainder != 0)) ||//and if center x is odd
            ((viewXRemainder != 0) &&//if view width is odd
             (viewCenterXRemainder == 0))) {//and if center x is even
                newCenter.x = oldCenter.x + viewXRemainder;
            }
    }

    CGFloat viewYRemainder = modf(viewSize.height/2,&intPart);
    CGFloat viewCenterYRemainder = modf(oldCenter.y/2, &intPart);
    
    if (anchor.y != 0.f && anchor.y != 1.f) {
        if (((viewYRemainder == 0) &&//if view width is even
             (viewCenterYRemainder != 0)) ||//and if center x is odd
            ((viewYRemainder != 0) &&//if view width is odd
             (viewCenterYRemainder == 0))) {//and if center x is even
                newCenter.y = oldCenter.y + viewYRemainder;
            }
    }
    
    return newCenter;
}

#pragma mark - Gestures
- (void)_handleTap:(UITapGestureRecognizer *)recognizer {
    MMHudLog(@"Handling tap");
    
    if ((self.cancelBlock != nil) &&
       (self.confirmed == NO)) {
        MMHudLog(@"Asking to confirm cancel");
        
        self.confirmed = YES;
        
        self.tempStatus = [self.status copy];
        CGFloat timerDuration = MMProgressHUDAnimateInDurationNormal*MMProgressHUDConfirmationPulseCount;
        self.confirmationTimer = [NSTimer scheduledTimerWithTimeInterval:timerDuration
                                                                  target:self
                                                                selector:@selector(_resetConfirmationTimer:)
                                                                userInfo:nil
                                                                 repeats:NO];
        
        self.status = self.confirmationMessage;
    
        [self.hud updateTitle:self.hud.titleText message:self.confirmationMessage animated:YES];
        
        
        
        [self _beginGlowAnimation];
    }
    else if (self.confirmed) {
        self.cancelled = YES;
        MMHudLog(@"confirmed to dismiss!");
        
        [self.confirmationTimer invalidate], self.confirmationTimer = nil;
        
        if (self.cancelBlock != nil) {
            self.cancelBlock();
        }
        
        self.hud.completionState = MMProgressHUDCompletionStateError;
        [self.hud setNeedsUpdate:YES];
        [self.hud updateAnimated:YES
                  withCompletion:^(__unused BOOL completed) {
            [self dismiss];
        }];
        
        self.confirmed = NO;
    }
}

- (void)_resetConfirmationTimer:(NSTimer *)timer {
    MMHudLog(@"Resetting confirmation timer");
    
    [self.confirmationTimer invalidate], self.confirmationTimer = nil;
    self.status = self.tempStatus;
    self.tempStatus = nil;
    
    self.confirmed = NO;
    
    [self _endGlowAnimation];
    
    [self.hud updateTitle:self.hud.titleText message:self.status animated:YES];
}

- (UIImage *)_imageForCompletionState:(MMProgressHUDCompletionState)completionState {
    switch (completionState) {
        case MMProgressHUDCompletionStateError:
            return self.errorImage;
        case MMProgressHUDCompletionStateSuccess:
            return self.successImage;
        case MMProgressHUDCompletionStateNone:
            return nil;
    }
}

#pragma mark - MMHud Delegate
- (void)hudDidCompleteProgress:(MMHud *)hud {
    if (self.progressCompletion != nil) {
        self.progressCompletion();
    }
    
    self.hud.accessibilityValue = nil;
}

- (UIImage *)hud:(MMHud *)hud imageForCompletionState:(MMProgressHUDCompletionState)completionState {
    return [self _imageForCompletionState:completionState];
}

- (CGPoint)hudCenterPointForDisplay:(MMHud *)hud {
    return [self _windowCenterForHUDAnchor:hud.layer.anchorPoint];
}

@end
