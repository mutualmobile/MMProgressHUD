//
//  MMProgressHUDPrivate.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"

@class MMRadialProgressView;

@interface MMProgressHUD() <MMHudDelegate>

@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) MMProgressHUDWindow *window;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, readwrite, getter = isVisible) BOOL visible;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSArray *animationImages;
@property (nonatomic, strong) CAAnimation *queuedShowAnimation;
@property (nonatomic, strong) CAAnimation *queuedDismissAnimation;
@property (nonatomic, assign) MMProgressHUDCompletionState completionState;
@property (nonatomic, strong) UIView *progressViewContainer;
@property (nonatomic, strong) MMRadialProgressView *radialProgressView;
@property (nonatomic, strong) MMProgressHUDOverlayView *overlayView;

- (void)_buildTextLabel;
- (void)_buildStatusLabel;
- (void)_buildHUDWindow;
- (void)_buildHUD;
- (void)_buildOverlayViewForMode:(MMProgressHUDWindowOverlayMode)overlayMode inView:(UIView *)view;
- (void)_updateMessageLabelsWithAnimationDuration:(CGFloat)animationDuration;
- (void)_updateHUDAnimated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completionBlock;
- (void)_updateHUD;
- (void)_layoutContentArea;
- (UIImage *)_imageForCompletionState:(MMProgressHUDCompletionState)completionState;
- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor;
- (void)forceCleanup;

#pragma mark - Animations
- (CAAnimationGroup *)_glowAnimation;
- (void)_beginGlowAnimation;
- (void)_endGlowAnimation;
- (void)_showWithDropAnimation;
- (void)_dismissWithDropAnimation;
- (void)_showWithExpandAnimation;
- (void)_dismissWithExpandAnimation;
- (void)_showWithShrinkAnimation;
- (void)_dismissWithShrinkAnimation;
- (void)_showWithSwingInAnimationFromLeft:(BOOL)fromLeft;
- (void)_dismissWithSwingRightAnimation;
- (void)_dismissWithSwingLeftAnimation;
- (void)_showWithBalloonAnimation;
- (void)_dismissWithBalloonAnimation;
- (void)_showWithFadeAnimation;
- (void)_dismissWithFadeAnimation;
//show
//dismiss
- (void)_executeShowAnimation:(CAAnimation *)animation;
- (void)_executeDismissAnimation:(CAAnimation *)animation;
- (CGPoint)_antialiasedPositionPointForPoint:(CGPoint)oldCenter forLayer:(CALayer *)layer;

#pragma mark - Animation Foundries
- (CAAnimation *)_dropAnimationIn;
- (CAAnimation *)_dropAnimationOut;
- (CAAnimation *)_shrinkAnimation:(BOOL)shrink animateOut:(BOOL)fadeOut;
- (CAAnimation *)_swingInAnimationFromLeft:(BOOL)fromLeft;
- (CAAnimation *)_moveInAnimation;
- (CAAnimation *)_fadeInAnimation;
- (CAAnimation *)_balloonAnimationIn;
- (CAAnimation *)_balloonAnimationOut;
- (CAAnimation *)_confettiAnimationOut;

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

#pragma mark - Gestures
- (void)_handleTap:(UITapGestureRecognizer *)recognizer;
- (void)_resetConfirmationTimer:(NSTimer *)timer;

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
        progressStyle:(MMProgressHUDProgressStyle)progressStyle;

- (void)dismissWithCompletionState:(MMProgressHUDCompletionState)completionState
                             title:(NSString *)title
                            status:(NSString *)status
                        afterDelay:(float)delay;

@end

@interface MMHud()

@property (nonatomic, strong, readwrite) UIView *progressViewContainer;
@property (nonatomic, readwrite) BOOL visible;

- (void)_buildTitleLabel;
- (void)_buildStatusLabel;

@end
