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

- (id<CAAction>)actionForKey:(NSString *)key{
    if ([key isEqualToString:@"progress"]) {
        CABasicAnimation *progressAnimation = [CABasicAnimation animation];
        progressAnimation.fromValue = [self.presentationLayer valueForKey:key];
        progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        return progressAnimation;
    }
    
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx{
    CGFloat insetWidth = 1.f/[[UIScreen mainScreen] scale];
    CGFloat radiusOffset = (self.contentsScale > 1) ? 0.5f : 0.f;
    CGRect rect = CGRectInset(CGRectIntegral(self.bounds), 1.f, 1.f);
    CGRect insetRect = CGRectInset(rect, insetWidth, insetWidth);
    
    CGFloat radius = truncf(MIN(CGRectGetMidX(insetRect), CGRectGetMidY(insetRect))) + radiusOffset;
    CGPoint center = CGPointMake(CGRectGetMidX(insetRect), CGRectGetMidY(insetRect));
    CGFloat topAngle = -(M_PI_2);
    CGFloat endAngle = topAngle + (2.f*M_PI) * self.progress;
    UIColor *backgroundFill = [UIColor colorWithWhite:1.0 alpha:0.2];
    UIColor *pieFillColor = [UIColor whiteColor];
    UIColor *borderStroke = [UIColor colorWithWhite:1.f alpha:0.5f];
    
    /** This is necessary since we're not calling this
        code in drawRect: in order to use UIKit draw methods.
        UIKit draw methods draw into the context at the top
        of the context stack, which in the case of this layer,
        is nil. Manually push a CGContextRef to the stack to
        draw on it.
     */
    UIGraphicsPushContext(ctx);
    
    CGRect innerCircleRect = CGRectInset(rect,
                                         CGRectGetWidth(insetRect)/5,
                                         CGRectGetHeight(insetRect)/5);
    
    CGContextSaveGState(ctx);
    {
        //create path for background
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:insetRect];
        UIBezierPath *innerCirclePath = [UIBezierPath bezierPathWithOvalInRect:innerCircleRect];
        
        [circlePath appendPath:innerCirclePath];
        [circlePath setUsesEvenOddFillRule:YES];
        [circlePath addClip];
        
        //fill background
        [backgroundFill setFill];
        [circlePath fill];
        
        //path for pie piece
        UIBezierPath *piePath = [UIBezierPath bezierPath];
        [piePath moveToPoint:center];
        [piePath addArcWithCenter:center
                           radius:radius
                       startAngle:topAngle
                         endAngle:endAngle
                        clockwise:YES];
        [piePath closePath];
        
        //fill pie piece
        [pieFillColor setFill];
        [piePath fill];
        
        //stroke border
        [borderStroke setStroke];
        [circlePath stroke];
        [innerCirclePath stroke];
    }
    CGContextRestoreGState(ctx);
    
    //stroke clear border to antialias
    CGRect outerAntialiasRect = CGRectInset(insetRect, -insetWidth/2, -insetWidth/2);
    CGRect innerAntialiasRect = CGRectInset(innerCircleRect, insetWidth/2, insetWidth/2);
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPathWithOvalInRect:outerAntialiasRect];
    UIBezierPath *innerCircleAntialiasPath = [UIBezierPath bezierPathWithOvalInRect:innerAntialiasRect];
    [outerCirclePath appendPath:innerCircleAntialiasPath];
    
    [[UIColor clearColor] setStroke];
    [innerCircleAntialiasPath setLineWidth:insetWidth];
    [outerCirclePath setLineWidth:insetWidth];
    [outerCirclePath stroke];
    [innerCircleAntialiasPath stroke];
    
    UIGraphicsPopContext();
}
@end

@implementation MMRadialProgressView

+ (Class)layerClass{
    return [MMRadialProgressLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
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
    NSUInteger options = (UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState);
    
    [UIView
     animateWithDuration:animated ? 0.25f : 0.f
     delay:0.f
     options:options
     animations:^{
         [((MMRadialProgressLayer *)self.layer) setProgress:progress];
     }
     completion:completion];
}

- (CGFloat)progress{
    return [((MMRadialProgressLayer *)self.layer) progress];
}

@end
