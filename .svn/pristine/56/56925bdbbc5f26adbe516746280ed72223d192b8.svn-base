//
//  MMRadialProgress.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 5/14/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMRadialProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface MMRadialProgressLayer : CALayer
@property (nonatomic) CGFloat progress;
@end

@implementation MMRadialProgressLayer

@dynamic progress;

+(BOOL)needsDisplayForKey:(NSString *)key{
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id)actionForKey:(NSString *)key{
    
    if ([key isEqualToString:@"progress"]) {
        CABasicAnimation *progressAnimation = [CABasicAnimation animation];
        progressAnimation.fromValue = [self.presentationLayer valueForKey:key];
        progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        return progressAnimation;
    }
    
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx{
    CGFloat insetWidth = 1.f;
    CGFloat radiusOffset = (self.contentsScale > 1) ? 0.5f : 0.f;
    CGRect rect = CGRectIntegral(self.bounds);
    CGRect insetRect = CGRectInset(rect, insetWidth, insetWidth);
    
    CGFloat radius = truncf(MIN(CGRectGetWidth(insetRect)/2, CGRectGetHeight(insetRect)/2)/* - insetWidth*2*/) + radiusOffset;
    CGPoint center = CGPointMake(CGRectGetWidth(insetRect)/2 + insetWidth, CGRectGetHeight(insetRect)/2 + insetWidth);
    CGFloat topAngle = -(M_PI/2);
    CGFloat endAngle = topAngle + (2*M_PI) * self.progress;
    
    //this is necessary since we're not calling this code in drawRect: in order to use UIKit draw methods.
    // UIKit draw methods draw into the context at the top of the context stack, which in the case
    // of this layer, is nil. Manually push a CGContextRef to the stack to draw on it.
    UIGraphicsPushContext(ctx);
    
    //create path for background
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:insetRect];
    
    //fill background
    [[UIColor colorWithWhite:1.0 alpha:0.2] setFill];
    [circlePath fill];
    
    //path for pie piece
    UIBezierPath *piePath = [UIBezierPath bezierPath];
    [piePath moveToPoint:center];
    [piePath addArcWithCenter:center radius:radius startAngle:topAngle endAngle:endAngle clockwise:YES];
    [piePath closePath];
    
    //fill pie piece
    [[UIColor whiteColor] setFill];
    [piePath fill];
    
    //stroke border
    [[UIColor whiteColor] setStroke];
    [circlePath stroke];
    
    //stroke clear border to antialias
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, insetWidth/2, insetWidth/2)];
    [[UIColor clearColor] setStroke];
    [outerCirclePath stroke];
    
    UIGraphicsPopContext();
    
    [super drawInContext:ctx];
}
@end

@implementation MMRadialProgressView

+ (Class)layerClass{
    return [MMRadialProgressLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.contentsScale = [[UIScreen mainScreen] scale];//set this or have fuzzy drawing on retina
        [self.layer setNeedsDisplay];//immediately draw empty circle
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    [self setProgress:progress animated:animated withCompletion:nil];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completion{
    [UIView
     animateWithDuration:animated ? 0.25f : 0.f
     delay:0.f
     options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         [((MMRadialProgressLayer *)self.layer) setProgress:progress];
     }
     completion:completion];
}

- (CGFloat)progress{
    return [((MMRadialProgressLayer *)self.layer) progress];
}

@end
