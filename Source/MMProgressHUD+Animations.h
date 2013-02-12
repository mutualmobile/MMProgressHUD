//
//  MMProgressHUD+Animations.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 7/2/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUD.h"

@class CAAnimationGroup;
@class CAAnimation;

@interface MMProgressHUD (Animations)

- (CAAnimationGroup *)_glowAnimation;
- (void)_beginGlowAnimation;
- (void)_endGlowAnimation;
- (void)_dismissWithDropAnimation;
- (void)_dismissWithExpandAnimation;
- (void)_dismissWithShrinkAnimation;
- (void)_dismissWithSwingLeftAnimation;
- (void)_dismissWithSwingRightAnimation;
- (void)_dismissWithBalloonAnimation;
- (void)_dismissWithFadeAnimation;
- (void)_showWithDropAnimation;
- (void)_showWithExpandAnimation;
- (void)_showWithShrinkAnimation;
- (void)_showWithSwingInAnimationFromLeft:(BOOL)left;
- (void)_showWithBalloonAnimation;
- (void)_showWithFadeAnimation;

- (void)_executeShowAnimation:(CAAnimation *)animation;
- (void)_executeDismissAnimation:(CAAnimation *)animation;

@property (nonatomic, retain, readwrite) CAAnimation *queuedDismissAnimation;
@property (nonatomic, retain, readwrite) CAAnimation *queuedShowAnimation;
@property (nonatomic, readwrite, getter = isVisible) BOOL visible;

@end
