//
//  MMProgressHUD+Animations.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 7/2/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MMProgressHUD+Animations.h"
#import "MMProgressHUDCommon.h"

@interface MMProgressHUD ()

- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor;

@end

@implementation MMProgressHUD (Animations)

@dynamic queuedShowAnimation;
@dynamic queuedDismissAnimation;
@dynamic visible;

#pragma mark - Animations
- (CAAnimationGroup *)_glowAnimation {
    CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowColor"];
    glowAnimation.fromValue = (id)self.hud.layer.shadowColor;
    glowAnimation.toValue = (id)self.glowColor;
    
    CABasicAnimation *shadowOpacity = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacity.fromValue = @(self.hud.layer.shadowOpacity);
    shadowOpacity.toValue = @1.f;
    
    CGColorRef whiteishColor = CGColorRetain([UIColor colorWithWhite:0.f alpha:0.85f].CGColor);
    
    CABasicAnimation *hudBackground = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    hudBackground.fromValue = (id)self.hud.layer.backgroundColor;
    hudBackground.toValue = (__bridge id)whiteishColor;
    
    CGColorRelease(whiteishColor);
    
    CAAnimationGroup *glowGroup = [CAAnimationGroup animation];
    glowGroup.animations = @[glowAnimation, shadowOpacity, hudBackground];
    glowGroup.duration = MMProgressHUDAnimateInDurationNormal;
    glowGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    glowGroup.autoreverses = YES;
    glowGroup.repeatCount = INFINITY;
    
    return glowGroup;
}

- (void)_beginGlowAnimation {
    
    CAAnimationGroup *glowGroup = [self _glowAnimation];
    
    [self.hud.layer addAnimation:glowGroup forKey:@"glow-animation"];
}

- (void)_endGlowAnimation {
    [self.hud.layer removeAnimationForKey:@"glow-animation"];
}

- (void)_showWithDropAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 0.f);
    
    CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.center = CGPointMake(newCenter.x, -CGRectGetHeight(self.hud.frame));
        self.hud.layer.opacity = 1.f;
        
        [self _executeShowAnimation:[self _dropAnimationIn]];
    }
    [CATransaction commit];
}

- (void)_dismissWithDropAnimation {
    
    double newAngle = arc4random_uniform(1000)/1000.f*M_2_PI-(M_2_PI)/2.f;
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, self.frame.size.height + self.hud.frame.size.height);
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeDismissAnimation:[self _dropAnimationOut]];

        // Don't shift the position if we're in a queue...
        if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyShowAnimation] == nil) {
        
            self.hud.layer.position = newPosition;
            self.hud.layer.transform = CATransform3DMakeRotation(newAngle, 0.f, 0.f, 1.f);
        }
    }
    [CATransaction commit];
}

- (void)_showWithExpandAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.position =  [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    self.hud.alpha = 0.f;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DIdentity;
        self.hud.layer.opacity = 1.0f;
        
        [self _executeShowAnimation:[self _shrinkAnimation:NO animateOut:NO]];
    }
    [CATransaction commit];
}

- (void)_dismissWithExpandAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {   
        self.hud.layer.transform = CATransform3DMakeScale(3.f, 3.f, 1.f);
        self.hud.layer.opacity = 0.f;
        
        [self _executeDismissAnimation:[self _shrinkAnimation:NO animateOut:YES]];
    }
    [CATransaction commit];
}

- (void)_showWithShrinkAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    self.hud.alpha = 0.f;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DIdentity;
        self.hud.layer.opacity = 1.0f;
        
        [self _executeShowAnimation:[self _shrinkAnimation:YES animateOut:NO]];
    }
    [CATransaction commit];
}

- (void)_dismissWithShrinkAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {   
        self.hud.layer.transform = CATransform3DMakeScale(0.25, 0.25, 1.f);
        self.hud.layer.opacity = 0.f;
        
        [self _executeDismissAnimation:[self _shrinkAnimation:YES animateOut:YES]];
    }
    [CATransaction commit];
}

- (void)_showWithSwingInAnimationFromLeft:(BOOL)fromLeft NS_EXTENSION_UNAVAILABLE_IOS("Not available in app extensions."){
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 0.0f);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.opacity = 1.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        
        [self _executeShowAnimation:[self _swingInAnimationFromLeft:fromLeft]];
    }
    [CATransaction commit];
}

- (void)_dismissWithSwingRightAnimation {
    [self _dismissWithDropAnimation];
}

- (void)_dismissWithSwingLeftAnimation {
    [self _dismissWithDropAnimation];
}

- (void)_showWithBalloonAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5, 1.0);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.opacity = 1.f;
        CGPoint center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        self.hud.layer.position = CGPointMake(center.x, CGRectGetHeight(self.frame) + CGRectGetHeight(self.hud.frame));
        //        self.hud.layer.position = center;
        
        
        [self _executeShowAnimation:[self _balloonAnimationIn]];
    }
    [CATransaction commit];
}

- (void)_dismissWithBalloonAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.hud.layer.transform = CATransform3DMakeRotation(M_PI_2, 0.f, 0.f, 1.f);
        
        [self _executeDismissAnimation:[self _balloonAnimationOut]];
        
        CGPoint center = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
        self.hud.layer.position = CGPointMake(center.x, -CGRectGetHeight(self.hud.frame));
    }
    [CATransaction commit];
}

- (void)_showWithFadeAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.transform = CATransform3DIdentity;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeShowAnimation:[self _fadeInAnimation]];
        
        self.hud.layer.opacity = 1.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    }
    [CATransaction commit];
}

- (void)_dismissWithFadeAnimation {
    self.hud.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.hud.layer.transform = CATransform3DIdentity;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        [self _executeDismissAnimation:[self _fadeOutAnimation]];
        
        self.hud.layer.opacity = 0.f;
        self.hud.layer.position = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    }
    [CATransaction commit];
}

#pragma mark - Animation Foundries
- (CAKeyframeAnimation *)_dropInAnimationPositionAnimationWithCenter:(CGPoint)newCenter {
    CAKeyframeAnimation *dropInPositionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.hud.center.x, self.hud.center.y);
    CGPathAddLineToPoint(path, NULL, newCenter.x - 10.f, newCenter.y - 2.f);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x, newCenter.y - 10.f,
                          newCenter.x + 10.f, newCenter.y - 10.f,
                          newCenter.x + 5.f, newCenter.y - 2.f);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x + 7, newCenter.y - 7.f,
                          newCenter.x, newCenter.y - 7.f,
                          newCenter.x - 3.f, newCenter.y);
    CGPathAddCurveToPoint(path, NULL,
                          newCenter.x, newCenter.y - 4.f,
                          newCenter.x , newCenter.y - 4.f,
                          newCenter.x, newCenter.y);
    
    dropInPositionAnimation.path = path;
    dropInPositionAnimation.calculationMode = kCAAnimationCubic;
    dropInPositionAnimation.keyTimes = @[@0.0f,
                                      @0.25f,
                                      @0.35f,
                                      @0.55f,
                                      @0.7f,
                                      @1.0f];
    dropInPositionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CGPathRelease(path);
    
    return dropInPositionAnimation;
}

- (CAKeyframeAnimation *)_dropInAnimationRotationAnimationWithInitialAngle:(CGFloat)initialAngle keyTimes:(NSArray *)keyTimes {
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.values = @[@(initialAngle),
                        @(-initialAngle * 0.85),
                        @(initialAngle * 0.6),
                        @(-initialAngle * 0.3),
                        @0.f];
    rotation.calculationMode = kCAAnimationCubic;
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotation.keyTimes = keyTimes;
    
    return rotation;
}

- (CAAnimation *)_dropAnimationIn {
    CGFloat initialAngle = M_2_PI/10.f + arc4random_uniform(1000)/1000.f*M_2_PI/5.f;
    CGPoint newCenter = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    
    MMHudLog(@"Center after drop animation: %@", NSStringFromCGPoint(newCenter));
    
    CAKeyframeAnimation *dropInAnimation = [self _dropInAnimationPositionAnimationWithCenter:newCenter];
    CAKeyframeAnimation *rotationAnimation = [self _dropInAnimationRotationAnimationWithInitialAngle:initialAngle
                                                                                   keyTimes:dropInAnimation.keyTimes];
    
    CAAnimationGroup *showAnimation = [CAAnimationGroup animation];
    showAnimation.animations = @[dropInAnimation, rotationAnimation];
    showAnimation.duration = MMProgressHUDAnimateInDurationLong;
    
    [self _executeShowAnimation:showAnimation];
    
    self.hud.layer.position = newCenter;
    self.hud.layer.transform = CATransform3DIdentity;
    
    return showAnimation;
}

- (CAAnimation *)_dropAnimationOut {
    double newAngle = arc4random_uniform(1000)/1000.f*M_2_PI-(M_2_PI)/2.f;
    CATransform3D rotation = CATransform3DMakeRotation(newAngle, 0.f, 0.f, 1.f);
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, self.frame.size.height + self.hud.frame.size.height);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:self.hud.layer.transform];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotation];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:self.hud.layer.position];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
    
    CAAnimationGroup *fallOffAnimation = [CAAnimationGroup animation];
    fallOffAnimation.animations = @[rotationAnimation, positionAnimation];
    fallOffAnimation.duration = MMProgressHUDAnimateOutDurationLong;
    fallOffAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fallOffAnimation.removedOnCompletion = YES;
    
    return fallOffAnimation;
}

- (CAAnimation *)_shrinkAnimation:(BOOL)shrink animateOut:(BOOL)fadeOut {
    CGFloat startingOpacity;// = fadeOut ? 1.0 : 0.f;
    CGFloat startingScale;// = shrink ? 0.25 : 1.0f;
    CGFloat endingOpacity;
    CGFloat endingScale;
    
    if (fadeOut) { //shrink & expand out
        startingOpacity = 1.f;
        startingScale = 1.f;
        endingOpacity = 0.f;
        
        if (shrink) {
            endingScale = 0.25f;
        }
        else {
            endingScale = 3.f;
        }
    }
    else {
        startingOpacity = 0.f;
        endingScale = 1.f;
        endingOpacity = 1.f;
        
        if (shrink) {//shrink in
            startingScale = 3.f;
        }
        else {//expand in
            startingScale = 0.25f;
        }
    }
    
    CAKeyframeAnimation *expand = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (fadeOut) {
        expand.keyTimes = @[@0.f,
                           @0.45f,
                           @1.0f];
        
        if (shrink) {
            expand.values = @[@(startingScale),
                             @(startingScale*1.2f),
                             @(endingScale)];
        }
        else {
            expand.values = @[@(startingScale),
                             @(startingScale*0.8f),
                             @(endingScale)];
        }
    }
    else {
        expand.keyTimes = @[@0.f,
                           @0.65f,
                           @0.80f,
                           @1.0f];
        
        if (shrink) {
            expand.values = @[@(startingScale),
                             @(endingScale*0.9f),
                             @(endingScale*1.1f),
                             @(endingScale)];
        }
        else {
            expand.values = @[@(startingScale),
                             @(endingScale*1.1f),
                             @(endingScale*0.9f),
                             @(endingScale)];
        }
    }
    
    expand.calculationMode = kCAAnimationCubic;
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(startingOpacity);
    fade.toValue = @(endingOpacity);
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[expand, fade];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.duration = fadeOut ? MMProgressHUDAnimateOutDurationShort : MMProgressHUDAnimateInDurationShort;
    
    return animationGroup;
}

- (CAAnimation *)_swingInAnimationFromLeft:(BOOL)fromLeft NS_EXTENSION_UNAVAILABLE_IOS("Not available in app extensions."){
    CAKeyframeAnimation *rotate = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    
    CGPoint endPoint = [self _windowCenterForHUDAnchor:self.hud.layer.anchorPoint];
    CGPoint startPoint;
    
    CGFloat height;
    CGFloat width;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint cp1;
    CGPoint cp2;
    
    if (UIInterfaceOrientationIsPortrait([[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation])) {
        height = CGRectGetHeight(self.window.frame);
        width = CGRectGetWidth(self.window.frame);
    }
    else {
        height = CGRectGetWidth(self.window.frame);
        width = CGRectGetHeight(self.window.frame);
    }
    
    if (fromLeft) { //swing in from left
        startPoint = CGPointMake(-CGRectGetWidth(self.hud.frame), 0.f);
        
        cp1 = CGPointMake(startPoint.x + 10.f, startPoint.y + height/4);
        cp2 = CGPointMake(endPoint.x - width/4, endPoint.y);
        
        rotate.values = @[[NSNumber numberWithFloat:M_PI_4],
                         @0.0f,
                         [NSNumber numberWithFloat:-M_PI_4/6],
                         [NSNumber numberWithFloat:M_PI_4/12],
                         @0.0f];
    }
    else {//swing in from right
        if (UIInterfaceOrientationIsPortrait([[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation])) {
            startPoint = CGPointMake(CGRectGetWidth(self.window.frame) + CGRectGetWidth(self.hud.frame), 0.f);
        }
        else {
            startPoint = CGPointMake(CGRectGetHeight(self.window.frame) + CGRectGetWidth(self.hud.frame), 0.f);
        }
        
        cp1 = CGPointMake(startPoint.x - 10.f, startPoint.y + height/4);
        cp2 = CGPointMake(endPoint.x + width/4, endPoint.y);
        
        rotate.values = @[[NSNumber numberWithFloat:-M_PI_4],
                         @0.0f,
                         [NSNumber numberWithFloat:M_PI_4/6],
                         [NSNumber numberWithFloat:-M_PI_4/12],
                         @0.0f];
    }

    MMHudLog(@"Start point: %@", NSStringFromCGPoint(startPoint));
    MMHudLog(@"End Point: %@", NSStringFromCGPoint(endPoint));
    
    MMHudLog(@"cp1: %@", NSStringFromCGPoint(cp1));
    MMHudLog(@"cp2: %@", NSStringFromCGPoint(cp2));
    
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path, NULL, cp1.x, cp1.y, cp2.x, cp2.y, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x - 5.f, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x + 3.f, endPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    CAKeyframeAnimation *swing = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    swing.path = path;
    swing.calculationMode = kCAAnimationCubic;
    swing.keyTimes = @[@0.0f,
                      @0.75f,
                      @0.8f,
                      @0.9f,
                      @1.0f];
    swing.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CGPathRelease(path);
    
    rotate.keyTimes = swing.keyTimes;
    rotate.timingFunctions = swing.timingFunctions;
    rotate.calculationMode = kCAAnimationCubic;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[swing, rotate];
    group.duration = MMProgressHUDAnimateInDurationMedium;
    
    return group;
}

- (CAAnimation *)_moveInAnimation {
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.33f;
    
    return transition;
}

- (CAAnimation *)_fadeInAnimation {
    NSString *opacityKey = @"opacity";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKey];
    NSNumber *currentValue = [self.hud.layer valueForKey:opacityKey];
    if ([currentValue floatValue] == 1.f) {
        animation.fromValue = @(0.f);
    }
    else {
        animation.fromValue = [self.hud.layer.presentationLayer valueForKey:opacityKey];;
    }
    animation.toValue = @(1.f);
    animation.duration = MMProgressHUDAnimateInDurationShort;
    
    return animation;
}

- (CAAnimation *)_fadeOutAnimation {
    NSString *opacityKey = @"opacity";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKey];
    animation.fromValue = [self.hud.layer.presentationLayer valueForKey:opacityKey];
    animation.toValue = @(0.f);
    animation.duration = MMProgressHUDAnimateOutDurationMedium;
    
    return animation;
}

- (CAAnimation *)_balloonAnimationIn {
    return [self _dropAnimationIn];
}

- (CAAnimation *)_balloonAnimationOut {
    CGPoint newPosition = CGPointMake(self.hud.layer.position.x, -self.hud.frame.size.height);
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.calculationMode = kCAAnimationCubic;
    
    CGPoint currentPosition = self.hud.layer.position;
    CGPoint travelVector = CGPointMake(newPosition.x - currentPosition.x, newPosition.y - currentPosition.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.hud.layer.position.x, self.hud.layer.position.y);
    CGPathAddCurveToPoint(path, NULL,
                          currentPosition.x, currentPosition.y + travelVector.y/4,
                          newPosition.x - 50.f, newPosition.y - travelVector.y/2,
                          newPosition.x, newPosition.y);
    
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    positionAnimation.rotationMode = kCAAnimationRotateAuto;
    positionAnimation.path = path;
    positionAnimation.duration = MMProgressHUDAnimateOutDurationLong;
    positionAnimation.removedOnCompletion = YES;
    
    CGPathRelease(path);
    
    return positionAnimation;
}

- (CAAnimation *)_confettiAnimationOut {
    //    self.hud.layer dr
    return nil;
}

#pragma mark - Execution
- (void)_executeShowAnimation:(CAAnimation *)animation {
    [animation setValue:MMProgressHUDAnimationShow forKey:@"name"];
    
    self.visible = YES;
    
    __typeof(self) __weak weakSelf = self;
    void(^showCompletion)(void) = ^(void) {
        MMProgressHUD *blockSelf = weakSelf;
        MMHudLog(@"Show animation ended: %@", blockSelf.hud);
        self.visible = YES;
        
        blockSelf.queuedShowAnimation = nil;
        
        if (blockSelf.showAnimationCompletion != nil) {
            blockSelf.showAnimationCompletion();
            blockSelf.showAnimationCompletion = nil;
        }
        
        
        if (blockSelf.queuedDismissAnimation != nil) {
            [blockSelf _executeDismissAnimation:blockSelf.queuedDismissAnimation];
            blockSelf.queuedDismissAnimation = nil;
        }
    };
    
    if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] != nil) {
        self.queuedShowAnimation = animation;
    }
    else if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyShowAnimation] == nil) {
        self.queuedShowAnimation = nil;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:showCompletion];
        {
            [self.hud.layer addAnimation:animation forKey:MMProgressHUDAnimationKeyShowAnimation];
        }
        [CATransaction commit];
    }
}

- (void)_executeDismissAnimation:(CAAnimation *)animation {
    [animation setValue:MMProgressHUDAnimationDismiss forKey:@"name"];
    
    self.visible = NO;
    
    __typeof(self) __weak weakSelf = self;
    void(^endCompletion)(void) = ^(void) {
        MMProgressHUD *blockSelf = weakSelf;
        MMHudLog(@"Dismiss animation ended");
        self.visible = NO;
        
        if (blockSelf.dismissAnimationCompletion != nil) {
            blockSelf.dismissAnimationCompletion();
            blockSelf.dismissAnimationCompletion = nil;
        }
        
        [blockSelf.hud removeFromSuperview];
        
        blockSelf.queuedDismissAnimation = nil;
        
        //reset for next presentation
        [blockSelf.hud prepareForReuse];
        
        if (blockSelf.queuedShowAnimation != nil) {
            [blockSelf _executeShowAnimation:blockSelf.queuedShowAnimation];
        }
    };
    
    if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyShowAnimation] != nil) {
        self.queuedDismissAnimation = animation;
    }
    else if ([self.hud.layer animationForKey:MMProgressHUDAnimationKeyDismissAnimation] == nil) {
        self.queuedDismissAnimation = nil;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:endCompletion];
        {
            [self.hud.layer addAnimation:animation forKey:MMProgressHUDAnimationKeyDismissAnimation];
        }
        [CATransaction commit];
    }
}

@end
