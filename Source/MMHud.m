//
//  MMHud.m
//  MMProgressHUD
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MMHud.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDCommon.h"
#import "MMProgressView-Protocol.h"
#import "MMRadialProgressView.h"

CGFloat    const MMProgressHUDDefaultFontSize           = 16.f;

CGFloat    const MMProgressHUDMaximumWidth              = 300.f;
CGFloat    const MMProgressHUDMinimumWidth              = 100.f;
CGFloat    const MMProgressHUDContentPadding            = 5.f;

CGFloat    const MMProgressHUDAnimateInDurationLong     = 1.5f;
CGFloat    const MMProgressHUDAnimateInDurationMedium   = 0.75f;
CGFloat    const MMProgressHUDAnimateInDurationNormal   = 0.35f;
CGFloat    const MMProgressHUDAnimateInDurationShort    = 0.25f;
CGFloat    const MMProgressHUDAnimateInDurationVeryShort= 0.15f;

CGFloat    const MMProgressHUDAnimateOutDurationLong    = 0.75f;
CGFloat    const MMProgressHUDAnimateOutDurationMedium  = 0.55f;
CGFloat    const MMProgressHUDAnimateOutDurationShort   = 0.35f;

CGSize const MMProgressHUDDefaultContentAreaSize = { 100.f, 100.f };
CGSize const MMProgressHUDProgressContentAreaSize = { 40.f, 40.f };
CGSize const MMProgressHUDProgressMaximumAreaSize = {200.0f, 200.0f};


NSString * const MMProgressHUDFontNameBold = @"HelveticaNeue-Bold";
NSString * const MMProgressHUDFontNameNormal = @"HelveticaNeue-Light";

#ifdef DEBUG
    #ifdef MM_HUD_FRAME_DEBUG
        static const BOOL MMProgressHUDFrameDebugModeEnabled = YES;
    #else
        static const BOOL MMProgressHUDFrameDebugModeEnabled = NO;
    #endif
#else
    static const BOOL MMProgressHUDFrameDebugModeEnabled = NO;
#endif

@interface MMHud()

@property (nonatomic, strong) UIView *progressViewContainer;
@property (nonatomic, strong) UIView <MMProgressView> *progressView;
@property (nonatomic, readwrite, getter = isVisible) BOOL visible;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) CGRect contentAreaFrame;
@property (nonatomic, assign) CGRect statusFrame;
@property (nonatomic, assign) CGRect titleFrame;

@end

@implementation MMHud

- (instancetype)init {
    if ( (self = [super init]) ) {
        _needsUpdate = YES;
        
        self.indeterminate = YES;
        
        [self configureInitialDisplayAttributes];
        
        self.isAccessibilityElement = YES;
        self.progressViewClass = [MMRadialProgressView class];
    }
    
    return self;
}

- (void)dealloc {
    MMHudLog(@"dealloc");
}

#pragma mark - Construction
- (void)buildHUDAnimated:(BOOL)animated {
    if (animated == YES) {
        [UIView
         animateWithDuration:MMProgressHUDAnimateInDurationNormal
         animations:^{
             [self buildHUDAnimated:NO];
         }];
    }
    else {
        [self applyLayoutFrames];
    }
}

- (CGSize)titleLabelSizeForTitleText:(NSString *)titleText {
    CGSize titleSize=CGSizeZero;
    NSInteger numberOfLines = 20;
    
    CGFloat lineHeight;
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        NSDictionary *attributes = @{NSFontAttributeName: self.titleLabel.font};
        lineHeight = [titleText sizeWithAttributes:attributes].height;
    }
    else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        lineHeight = [titleText sizeWithFont:self.titleLabel.font].height;
#pragma clang diagnostic pop
    }
    CGFloat targetWidthIncrementor = 25.f;
    for (CGFloat targetWidth = MMProgressHUDMinimumWidth; numberOfLines > 2; targetWidth += targetWidthIncrementor) {
        if (targetWidth >= MMProgressHUDMaximumWidth){
            break;
        }
        
        CGSize boundingRect = CGSizeMake(targetWidth, 500.f);
        if ([self respondsToSelector:@selector(setTintColor:)]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            
            NSDictionary *attributes = @{NSFontAttributeName: self.titleLabel.font,
                                         NSParagraphStyleAttributeName : paragraphStyle};
            
            titleSize = [titleText boundingRectWithSize:boundingRect
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:NULL].size;
        }
        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            titleSize = [titleText sizeWithFont:self.titleLabel.font
                              constrainedToSize:boundingRect];
#pragma clang diagnostic pop
        }
        numberOfLines = titleSize.height/lineHeight;
    }
    return titleSize;
}

- (void)layoutContentAreaForCurrentState {
    if ((self.image || self.animationImages.count > 0) &&
        self.completionState == MMProgressHUDCompletionStateNone) {
        self.contentAreaFrame = CGRectMake(0.f,
                                           CGRectGetMaxY(self.titleFrame) + MMProgressHUDContentPadding,
                                           MMProgressHUDDefaultContentAreaSize.width,
                                           MMProgressHUDDefaultContentAreaSize.height);
    }
    else if (self.completionState == MMProgressHUDCompletionStateError ||
            self.completionState == MMProgressHUDCompletionStateSuccess) {
        UIImage *image = [self.delegate hud:self imageForCompletionState:self.completionState];
        self.contentAreaFrame = CGRectMake(0.f,
                                           CGRectGetMaxY(self.titleFrame) + MMProgressHUDContentPadding,
                                           image.size.width,
                                           image.size.height);
    }
    else {
        if (self.isIndeterminate) {
            self.contentAreaFrame = CGRectMake(0.f,
                                               CGRectGetMaxY(self.titleFrame) + MMProgressHUDContentPadding,
                                               CGRectGetWidth(self.activityIndicator.frame),
                                               CGRectGetHeight(self.activityIndicator.frame));
        }
        else {
            CGSize fittingSize = [[self progressViewClass] sizeThatFitsSize:MMProgressHUDProgressContentAreaSize maximumAvailableSize:MMProgressHUDProgressMaximumAreaSize];
            
            self.contentAreaFrame = (CGRect) {{0.f,
                CGRectGetMaxY(self.titleFrame) + MMProgressHUDContentPadding}, fittingSize};
        }
    }
}

- (CGSize)statusSizeForMessageText {
    CGSize statusSize = CGSizeZero;
    CGFloat additiveHeightConstant = 35.f;//35 is a fudge number from trial/error
    CGFloat targetWidthIncrementor = 25.f;
    for (CGFloat targetWidth = MMProgressHUDMinimumWidth; statusSize.width < statusSize.height + additiveHeightConstant; targetWidth += targetWidthIncrementor) {
        if (targetWidth >= MMProgressHUDMaximumWidth)
            break;
        
        CGSize boundingRect = CGSizeMake(targetWidth, 500.f);
        if ([self respondsToSelector:@selector(setTintColor:)]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            
            NSDictionary *attributes = @{NSFontAttributeName: self.statusLabel.font,
                                         NSParagraphStyleAttributeName : paragraphStyle};
            
            statusSize = [self.messageText boundingRectWithSize:boundingRect
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributes
                                                context:NULL].size;
        }
        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            statusSize = [self.messageText sizeWithFont:self.statusLabel.font
                              constrainedToSize:boundingRect];
#pragma clang diagnostic pop
        }
    }
    return statusSize;
}

- (void)layoutLabelFramesForStatusSize:(CGSize)statusSize titleSize:(CGSize)titleSize {
    CGFloat largerContentDimension = MAX(titleSize.width, statusSize.width);
    CGFloat upperBoundedContentWidth = MIN(largerContentDimension, MMProgressHUDMaximumWidth);
    CGFloat boundedContentWidth = MAX(upperBoundedContentWidth, MMProgressHUDMinimumWidth);
    CGFloat hudWidth = boundedContentWidth;
    
    if (self.titleText) {
        self.titleFrame = CGRectIntegral(CGRectMake(self.titleFrame.origin.x,
                                                    self.titleFrame.origin.y,
                                                    hudWidth,
                                                    self.titleFrame.size.height));
    }
    
    if (self.messageText) {
        self.statusFrame = CGRectIntegral(CGRectMake(self.statusFrame.origin.x,
                                                     self.statusFrame.origin.y,
                                                     hudWidth,
                                                     self.statusFrame.size.height));
    }
}

- (void)layoutChildContentFramesForFinalHUDBounds:(CGRect)finalHudBounds {
    //center stuff
    self.titleFrame = CGRectMake(MMProgressHUDContentPadding,
                                 self.titleFrame.origin.y,
                                 CGRectGetWidth(finalHudBounds),
                                 CGRectGetHeight(self.titleFrame));
    self.statusFrame = CGRectMake(MMProgressHUDContentPadding,
                                  self.statusFrame.origin.y,
                                  CGRectGetWidth(finalHudBounds),
                                  CGRectGetHeight(self.statusFrame));
    self.contentAreaFrame = CGRectMake(CGRectGetWidth(finalHudBounds)/2
                                       - CGRectGetWidth(self.contentAreaFrame)/2
                                       + MMProgressHUDContentPadding,
                                       self.contentAreaFrame.origin.y,
                                       CGRectGetWidth(self.contentAreaFrame),
                                       CGRectGetHeight(self.contentAreaFrame));
    
    self.titleFrame = CGRectIntegral(self.titleFrame);
    self.statusFrame = CGRectIntegral(self.statusFrame);
    self.contentAreaFrame = CGRectIntegral(self.contentAreaFrame);
}

- (void)updateLayoutFrames {
    
    self.titleFrame = CGRectZero;
    self.statusFrame = CGRectZero;
    self.contentAreaFrame = CGRectZero;
    
    CGSize titleSize = CGSizeZero;
    
    if (self.titleText != nil) {
        titleSize = [self titleLabelSizeForTitleText:self.titleText];
        
        self.titleFrame = CGRectMake(MMProgressHUDContentPadding,
                                     MMProgressHUDContentPadding,
                                     titleSize.width,
                                     titleSize.height);
    }
    
    [self layoutContentAreaForCurrentState];
    
    if (self.titleText == nil) {
        //adjust content area frame to compensate for extra padding that would have been around title label
        self.contentAreaFrame = CGRectOffset(self.contentAreaFrame,
                                             0.f,
                                             MMProgressHUDContentPadding);
    }
    
    CGSize statusSize = CGSizeZero;
    if (self.messageText != nil) {
        statusSize = [self statusSizeForMessageText];
        
        self.statusFrame = CGRectMake(MMProgressHUDContentPadding,
                                      CGRectGetMaxY(self.contentAreaFrame) + MMProgressHUDContentPadding,
                                      statusSize.width,
                                      statusSize.height);
    }
    
    [self layoutLabelFramesForStatusSize:statusSize titleSize:titleSize];
    
    CGRect imageTitleRect = CGRectUnion(self.titleFrame, self.contentAreaFrame);
    CGRect finalHudBounds = CGRectUnion(imageTitleRect, self.statusFrame);
    
    [self layoutChildContentFramesForFinalHUDBounds:finalHudBounds];
    
    [self _layoutContentArea];
    
    self.needsUpdate = NO;
}

- (void)configureInitialDisplayAttributes {
    CGColorRef blackColor = CGColorRetain([UIColor blackColor].CGColor);
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    self.layer.shadowColor  = blackColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 15.0f;
    self.layer.cornerRadius = 10.0f;
    
    CGColorRelease(blackColor);
    
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)frameInitialHUDPositionOffscreenWithDelegate:(id<MMHudDelegate>)localDelegate finalHudBounds:(CGRect)finalHudBounds {
    //create offscreen
    CGRect hudRect;
    CGPoint center = [localDelegate hudCenterPointForDisplay:self];
    
    hudRect = CGRectMake(roundf(center.x - CGRectGetWidth(finalHudBounds)/2),
                         roundf(-finalHudBounds.size.height*2),
                         CGRectGetWidth(finalHudBounds),
                         CGRectGetHeight(finalHudBounds));
    
    
    hudRect = CGRectIntegral(CGRectInset(hudRect, -MMProgressHUDContentPadding, -MMProgressHUDContentPadding));
    
    self.frame = hudRect;
    
    [self configureInitialDisplayAttributes];
}

- (void)frameHUDPositionPreservingCenterWithDelegate:(id<MMHudDelegate>)localDelegate finalHudBounds:(CGRect)finalHudBounds {
    //preserve center
    CGRect hudRect;
    CGPoint center;
    if (self.isVisible) {
        center = [localDelegate hudCenterPointForDisplay:self];
    }
    else {
        center = self.center;
    }
    
    CGFloat hudWidth = CGRectGetWidth(finalHudBounds);
    CGFloat hudHeight = CGRectGetHeight(finalHudBounds);
    CGFloat originX = roundf(center.x - self.layer.anchorPoint.x * hudWidth);
    CGFloat originYAnchorPointOffset = (0.5 - self.layer.anchorPoint.y) * 2.f * MMProgressHUDContentPadding;
    CGFloat originY = roundf(center.y - self.layer.anchorPoint.y * hudHeight + originYAnchorPointOffset);
    
    hudRect = CGRectMake(originX, originY,
                         hudWidth, hudHeight);
    
    hudRect = CGRectIntegral(CGRectInset(hudRect, -MMProgressHUDContentPadding, -MMProgressHUDContentPadding));
    
    self.frame = hudRect;
}

- (void)applyLayoutFrames {
    if (self.needsUpdate == YES) {
        [self updateLayoutFrames];
    }
    
    if (self.titleText == nil) {
        self.statusLabel.font = [UIFont fontWithName:MMProgressHUDFontNameBold
                                                size:MMProgressHUDDefaultFontSize];
    }
    else {
        self.statusLabel.font = [UIFont fontWithName:MMProgressHUDFontNameNormal
                                                size:MMProgressHUDDefaultFontSize];
    }
    
    //animate text change
    CATransition *crossfadeTransition = [CATransition animation];
    crossfadeTransition.duration = MMProgressHUDAnimateInDurationVeryShort;
    crossfadeTransition.type = kCATransitionFade;
    crossfadeTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.titleLabel.layer addAnimation:crossfadeTransition forKey:@"changeTextTransition"];
    [self.statusLabel.layer addAnimation:crossfadeTransition forKey:@"changeTextTransition"];
    
    self.titleLabel.text = self.titleText;
    self.statusLabel.text = self.messageText;
    
    //update container
    CGRect imageTitleRect = CGRectUnion(self.titleFrame, self.contentAreaFrame);
    CGRect finalHudBounds = CGRectUnion(imageTitleRect, self.statusFrame);
    
    id<MMHudDelegate> localDelegate = self.delegate;
    
    if (CGRectEqualToRect(self.frame, CGRectZero) == NO) {
        [self frameHUDPositionPreservingCenterWithDelegate:localDelegate
                                            finalHudBounds:finalHudBounds];
    }
    else {
        [self frameInitialHUDPositionOffscreenWithDelegate:localDelegate
                                            finalHudBounds:finalHudBounds];
    }
    
    //update subviews' frames
    self.titleLabel.frame = self.titleFrame;
    self.statusLabel.frame = self.statusFrame;
    self.progressViewContainer.frame = self.contentAreaFrame;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                          cornerRadius:self.layer.cornerRadius];
    self.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Updating Content
- (void)updateTitle:(NSString *)title animated:(BOOL)animated {
    self.titleText = title;
    
    [self updateAnimated:animated withCompletion:nil];
}

- (void)updateMessage:(NSString *)message animated:(BOOL)animated {
    self.messageText = message;
    
    [self updateAnimated:animated withCompletion:nil];
}

- (void)updateTitle:(NSString *)title message:(NSString *)message animated:(BOOL)animated {
    self.messageText = message;
    self.titleText = title;
    
    [self updateAnimated:animated withCompletion:nil];
}

- (void)updateAnimated:(BOOL)animated withCompletion:(void(^)(BOOL completed))updateCompletion {
    if (animated) {
        [UIView
         animateWithDuration:MMProgressHUDAnimateInDurationShort
         delay:0.f
         options:UIViewAnimationOptionCurveLinear
         animations:^{
             [self applyLayoutFrames];
         }
         completion:updateCompletion];
    }
    else {
        [self applyLayoutFrames];
        
        if (updateCompletion != nil) {
            updateCompletion(YES);
        }
    }
}

#pragma mark - Private Methods
- (UIViewContentMode)contentModeForImage:(UIImage *)image {
    //layout imageview content mode
    UIViewContentMode contentMode;
    CGFloat xRatio = image.size.width/CGRectGetWidth(self.imageView.frame);
    CGFloat yRatio = image.size.height/CGRectGetHeight(self.imageView.frame);
    if ((xRatio < 1.f) &&
        (yRatio < 1.f)) {
        contentMode = UIViewContentModeCenter;
    }
    else if ((xRatio > 1.f) &&
            (yRatio > 1.f)) {
        contentMode = UIViewContentModeScaleAspectFit;
    }
    else {
        contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return contentMode;
}

- (void)_layoutContentArea {
    //hud should already be the correct size before getting into this method
    self.progressViewContainer.frame = self.contentAreaFrame;
    
    self.imageView.hidden = (self.image == nil && self.animationImages.count == 0);
    self.progressView.hidden = self.isIndeterminate;
    
    if (self.completionState == MMProgressHUDCompletionStateNone) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        if (self.animationImages.count > 0) {
            self.imageView.image = nil;
            self.imageView.animationImages = self.animationImages;
            
            [self.activityIndicator stopAnimating];
            
            if (self.animationLoopDuration) {
                self.imageView.animationDuration = self.animationLoopDuration;
            }
            else {
                self.imageView.animationDuration = 0.5;
            }
            
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self.imageView startAnimating];
        }
        else if (self.image != nil) {
            self.imageView.animationImages = nil;
            self.imageView.image = self.image;
            
            [self.activityIndicator stopAnimating];
            
            self.imageView.contentMode = [self contentModeForImage:self.imageView.image];
        }
        else {
            self.imageView.hidden = YES;
            
            if (self.isIndeterminate) {
                [self.activityIndicator startAnimating];
                
                self.imageView.image = nil;
                self.imageView.animationImages = nil;
                
                [self.progressViewContainer addSubview:self.activityIndicator];
            }
            else {
                [self.activityIndicator stopAnimating];
            }
        }
        
        [CATransaction commit];
    }
    else {
        UIImage *completionImage = [self.delegate hud:self imageForCompletionState:self.completionState];
        UIViewAnimationOptions animationOptions =
            UIViewAnimationOptionTransitionCrossDissolve |
            UIViewAnimationOptionBeginFromCurrentState |
            UIViewAnimationOptionCurveEaseInOut |
            UIViewAnimationOptionAllowAnimatedContent;
        
        [UIView
         transitionWithView:self.progressViewContainer
         duration:MMProgressHUDAnimateInDurationVeryShort
         options:animationOptions
         animations:^{
             [CATransaction begin];
             [CATransaction setDisableActions:YES];
             {
                 [self.imageView stopAnimating];
                 
                 self.imageView.contentMode = [self contentModeForImage:completionImage];
                 
                 [self.activityIndicator stopAnimating];
                 self.progressView.hidden = YES;
                 
                 self.imageView.image = completionImage;
                 self.imageView.hidden = NO;
             }
             [CATransaction commit];
         }
         completion:nil];
    }
    
    self.completionState = MMProgressHUDCompletionStateNone;
}

- (void)_buildStatusLabel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _statusLabel.numberOfLines = 0;
        if ([UICollectionView class]) {
            _statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _statusLabel.textAlignment = NSTextAlignmentCenter;
        }
        else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _statusLabel.lineBreakMode = UILineBreakModeWordWrap;
            _statusLabel.textAlignment = UITextAlignmentCenter;
#pragma clang diagnostic pop
        }
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = [UIFont fontWithName:MMProgressHUDFontNameNormal size:MMProgressHUDDefaultFontSize];
        _statusLabel.textColor = [UIColor colorWithWhite:0.9f alpha:0.95f];
        _statusLabel.shadowColor = [UIColor blackColor];
        _statusLabel.shadowOffset = CGSizeMake(0, -1);
        
#ifdef MM_HUD_FRAME_DEBUG
        CGColorRef redColor = CGColorRetain([UIColor redColor].CGColor);
        
        _statusLabel.layer.borderColor = redColor;
        _statusLabel.layer.borderWidth = 1.f;
        
        CGColorRelease(redColor);
#endif
        
        [self addSubview:_statusLabel];
    }
#pragma clang diagnostic pop
}

- (void)_buildTitleLabel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.numberOfLines = 0;
        if ([UICollectionView class]) {
            _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
            _titleLabel.textAlignment = UITextAlignmentCenter;
#pragma clang diagnostic pop
        }
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont fontWithName:MMProgressHUDFontNameBold size:MMProgressHUDDefaultFontSize];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        
#ifdef MM_HUD_FRAME_DEBUG
        CGColorRef blueColor = CGColorRetain([UIColor blueColor].CGColor);
        
        _titleLabel.layer.borderColor = blueColor;
        _titleLabel.layer.borderWidth = 1.f;
        
        CGColorRelease(blueColor);
#endif
        
        [self addSubview:_titleLabel];
    }
#pragma clang diagnostic pop
}

#pragma mark - Property Overrides
- (void)setProgressStyle:(MMProgressHUDProgressStyle)progressStyle {
    _progressStyle = progressStyle;
    
    MMHudWLog(@"Setting %@ is deprecated, please set an explicit determinate progress class using %@",
              NSStringFromSelector(@selector(progressStyle)),
              NSStringFromSelector(@selector(progressViewClass)));
    
    self.indeterminate = (progressStyle == MMProgressHUDProgressStyleIndeterminate);
}

- (void)setProgressViewClass:(Class)progressViewClass {
    if (progressViewClass != Nil) {
        Protocol * __unused expectedProtocol = @protocol(MMProgressView);
        
        NSAssert([progressViewClass conformsToProtocol:expectedProtocol], @"Class %@ doesn't conform to %@ protocol", NSStringFromClass(progressViewClass), NSStringFromProtocol(expectedProtocol));
    }
    else {
        [self setIndeterminate:YES];
    }
    
    _progressViewClass = progressViewClass;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.progressViewContainer.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeCenter;
        [self.progressViewContainer addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIView <MMProgressView> *)progressView {
    if (_progressView == nil ||
        (_progressView.class != self.progressViewClass)) {
        _progressView = [[self.progressViewClass alloc] initWithFrame:self.progressViewContainer.bounds];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.progressViewContainer addSubview:_progressView];
    }
    
    return _progressView;
}

- (UIView *)progressViewContainer {
    if (_progressViewContainer == nil) {
        _progressViewContainer = [[UIView alloc] initWithFrame:self.contentAreaFrame];
        _progressViewContainer.backgroundColor = [UIColor clearColor];
        
#ifdef MM_HUD_FRAME_DEBUG
        CGColorRef yellowColor = CGColorRetain([UIColor yellowColor].CGColor);
        
        _progressViewContainer.layer.borderColor = yellowColor;
        _progressViewContainer.layer.borderWidth = 1.f;
        
        CGColorRelease(yellowColor);
#endif
        
        [self addSubview:_progressViewContainer];
    }
    
    return _progressViewContainer;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:YES];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
    _progress = progress;
    
    __typeof(self) __weak weakSelf = self;
    
    void(^completionBlock)(BOOL completed) = ^(BOOL completed) {
        MMHud *blockSelf = weakSelf;
        id blockDelegate = blockSelf.delegate;
        
        if ( (completed == YES) &&
            (progress >= 1.f) &&
            ([blockDelegate respondsToSelector:@selector(hudDidCompleteProgress:)] == YES)) {
            [blockDelegate hudDidCompleteProgress:blockSelf];
        }
    };
    
    [self.progressView setProgress:progress
                                animated:animated
                          withCompletion:completionBlock];
#pragma clang diagnostic pop
}

- (void)setIndeterminate:(BOOL)indeterminate {
    if (!indeterminate && self.progressViewClass == Nil) {
        MMHudWLog(@"HUD %@ set to determinate progress but progress view class is Nil", self);
    }
    
    if (indeterminate != self.isIndeterminate) {
        _indeterminate = indeterminate;
        [self setNeedsUpdate:YES];
    }
}

- (UILabel *)statusLabel {
    [self _buildStatusLabel];
    
    return _statusLabel;
}

- (UILabel *)titleLabel {
    [self _buildTitleLabel];
    
    return _titleLabel;
}

- (void)setMessageText:(NSString *)messageText {
    if ([messageText isEqualToString:self.messageText]) {
        return;
    }
    
    _messageText = [messageText copy];
    if (self.titleText == nil) {
        self.accessibilityLabel = _messageText;
    }
    else {
        self.accessibilityHint = _messageText;
    }
    
    [self setNeedsUpdate:YES];
}

- (void)setTitleText:(NSString *)titleText {
    if ([titleText isEqualToString:self.titleText]) {
        return;
    }
    
    _titleText = [titleText copy];
    
    self.accessibilityLabel = _titleText;
    
    [self setNeedsUpdate:YES];
}

- (void)setDisplayStyle:(MMProgressHUDDisplayStyle)style {
    _displayStyle = style;
    
    switch (style) {
        case MMProgressHUDDisplayStyleBordered:{
            CGColorRef whiteColor = CGColorRetain([UIColor whiteColor].CGColor);
            self.layer.borderColor = whiteColor;
            self.layer.borderWidth = 2.0f;
            CGColorRelease(whiteColor);
        }
            break;
        case MMProgressHUDDisplayStylePlain:
            self.layer.borderWidth = 0.0f;
            break;
    }
}

- (void)prepareForReuse {
    self.titleLabel.text = nil;
    self.statusLabel.text = nil;
    self.imageView.image = nil;
    self.imageView.animationImages = nil;
    self.progress = 0.f;
    self.layer.transform = CATransform3DIdentity;
    self.layer.opacity = 1.f;
    self.completionState = MMProgressHUDCompletionStateNone;
    self.visible = NO;
}

@end
