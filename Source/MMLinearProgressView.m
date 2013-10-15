//
//  MMLinearProgressView.m
//  MMProgressHUD
//
//  Created by Jonas Gessner on 04.08.13.
//  Copyright (c) 2012 Jonas Gessner. All rights reserved.
//

#import "MMLinearProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface MMLinearProgressLayer : CALayer
@property (nonatomic) CGFloat progress;
@end

@implementation MMLinearProgressLayer

@dynamic progress;

- (id)initWithLayer:(id)layer{
    self = [super initWithLayer:layer];
    if (self) {
        if ([layer isKindOfClass:[MMLinearProgressLayer class]]) {
            MMLinearProgressLayer *layerToCopy = (MMLinearProgressLayer *)layer;
            self.progress = layerToCopy.progress;
        }
    }
    return self;
}

+(BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        CABasicAnimation *progressAnimation = [CABasicAnimation animation];
        progressAnimation.fromValue = [self.presentationLayer valueForKey:key];
        progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        return progressAnimation;
    }
    
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);
    
	CGRect rect = CGRectInset(self.bounds, 1.0f, 1.0f);
    
	CGFloat radius = roundf(0.5f*(rect.size.height));
    
    CGContextSetAllowsAntialiasing(ctx, TRUE);
    
	[[UIColor whiteColor] set];
    
    UIBezierPath *stroker = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    
    [stroker setLineWidth:2.0f];
    [stroker stroke];
    
	// draw the inside moving filled rounded rectangle
	rect = CGRectInset(rect, 3.0f, 3.0f);
	radius = 0.5f * rect.size.height;
    
	// make sure the filled rounded rectangle is not smaller than 2 times the radius
	rect.size.width *= self.progress;
	if (rect.size.width < 2 * radius) {
		rect.size.width = 2 * radius;
    }
    
    UIBezierPath *filler = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [filler setLineWidth:2.0f];
    [filler fill];
    
    UIGraphicsPopContext();
}

@end


@implementation MMLinearProgressView

+ (CGSize)sizeThatFitsSize:(CGSize)defaultSize maximumAvailableSize:(CGSize)totalAvailableSize {
    float aspectRatio = (11.0f/140.0f);
    CGFloat expectedHeight = roundf(totalAvailableSize.width*aspectRatio);
    if (expectedHeight > totalAvailableSize.height) {
        return CGSizeMake(roundf(totalAvailableSize.width/aspectRatio), totalAvailableSize.height);
    }
    else {
        return CGSizeMake(totalAvailableSize.width, roundf(totalAvailableSize.width*aspectRatio));
    }
}

+ (Class)layerClass {
    return [MMLinearProgressLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.contentsScale = [[UIScreen mainScreen] scale];//set this or have fuzzy drawing on retina
        [self.layer setNeedsDisplay];//immediately draw empty circle
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self setProgress:progress animated:animated withCompletion:nil];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completion {    
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    if (animated == NO) {
        [CATransaction setDisableActions:YES];
    }
    
    [CATransaction setCompletionBlock:^{
        if (completion) {
            completion(YES);
        }
    }];
    
    [((MMLinearProgressLayer *)self.layer) setProgress:progress];
    
    [CATransaction commit];
}

- (CGFloat)progress {
    return [((MMLinearProgressLayer *)self.layer) progress];
}

@end
