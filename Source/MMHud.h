//
//  MMHud.h
//  MMProgressHUD
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#define MMExtern extern "C"
#else
#define MMExtern extern
#endif

MMExtern CGFloat const MMProgressHUDAnimateInDurationLong;
MMExtern CGFloat const MMProgressHUDAnimateInDurationNormal;
MMExtern CGFloat const MMProgressHUDAnimateInDurationMedium;
MMExtern CGFloat const MMProgressHUDAnimateInDurationShort;
MMExtern CGFloat const MMProgressHUDAnimateInDurationVeryShort;

MMExtern CGFloat const MMProgressHUDAnimateOutDurationLong;
MMExtern CGFloat const MMProgressHUDAnimateOutDurationMedium;
MMExtern CGFloat const MMProgressHUDAnimateOutDurationShort;

typedef NS_ENUM(NSInteger, MMProgressHUDDisplayStyle) {
    MMProgressHUDDisplayStylePlain = 0,
    MMProgressHUDDisplayStyleBordered,
};

typedef NS_ENUM(NSInteger, MMProgressHUDProgressStyle) {
    MMProgressHUDProgressStyleIndeterminate = 0,
    MMProgressHUDProgressStyleRadial,
    MMProgressHUDProgressStyleLinear,
} DEPRECATED_ATTRIBUTE;

typedef NS_ENUM(NSInteger, MMProgressHUDCompletionState) {
    MMProgressHUDCompletionStateNone = 0,
    MMProgressHUDCompletionStateError,
    MMProgressHUDCompletionStateSuccess,
};

@class MMHud;

@protocol MMHudDelegate <NSObject>

//-----------------------------------------------
/** @name Optional */
//-----------------------------------------------

@optional
/** Optional delegate method that is called when progress fed to MMHud equals to or exceeds 1.0f.
 
 @param hud The HUD view that is calling back to the delegate.
 */
- (void)hudDidCompleteProgress:(MMHud *)hud;

//-----------------------------------------------
/** @name Required */
//-----------------------------------------------

@required
/** Required delegate method that is called when the HUD view wants to know where it should position itself after animation.
 
 @param hud The HUD view that is requesting a center position.
 */
- (CGPoint)hudCenterPointForDisplay:(MMHud *)hud;

/** Required delegate method that is called when the HUD view needs an image based on a specified completion state.
 
 @param hud The HUD view that is requesting a center position.
 @param completionState The completion state that the HUD is requesting an image.
 */
- (UIImage *)hud:(MMHud *)hud imageForCompletionState:(MMProgressHUDCompletionState)completionState;

@end

@interface MMHud : UIView
//-----------------------------------------------
/** @name Properties */
//-----------------------------------------------

/** The title label that displays text stored in titleText.
 
 @warning Do not manually assign text to this property. Set the intended text with titleText and call applyLayoutFrames or updateAnimated:withCompletion:.
 */
@property (nonatomic, strong) UILabel *titleLabel;

/** The status label that displays text stored in messageText.
 
 @warning Do not manually assign text to this property.  Set the intended text with messageText and call applyLayoutFrames or updateAnimated:withCompletion:.
 */
@property (nonatomic, strong) UILabel *statusLabel;

/** The imageView that displays image content stored in either image or animationImages.
 
 @warning Do not manually assign images to this property. Set the intended image/images to image/animationImages respectively, then call applyLayoutFrames or updateAnimated:withCompletion:.
 */
@property (nonatomic, strong) UIImageView *imageView;

/** The completion state of the HUD. Used by the HUD to call out to the delegate to query for a completion image.
 */
@property (nonatomic, assign) MMProgressHUDCompletionState completionState;

/** A Boolean value that indicates whether or not the HUD is visible. 
 
 @warning Managed internally.
 */
@property (nonatomic, readonly,
           getter = isVisible) BOOL visible;

/** The display style for the HUD.
 
 Persistent across show calls (does not get reset when prepareForReuse is called).
 */
@property (nonatomic, assign) MMProgressHUDDisplayStyle displayStyle;

/** An enum to specifiy the style in which to display progress.
 
 The default style is indeterminate progress.
 
 @warning Deprecated: To use determinate progress, set a progressViewClass on either MMProgressHUD or MMHud and call showDeterminateProgressWithTitle:status and friends. All other show methods default to indeterminate progress.
 */
@property (nonatomic, assign) MMProgressHUDProgressStyle progressStyle DEPRECATED_ATTRIBUTE;

/** A boolean to indicate whether or not the HUD has indeterminate progess. When set to NO the HUD will display a progress view which can be customized by setting the progressViewClass.
 
 The default value is YES
 */
@property (nonatomic, assign, getter = isIndeterminate) BOOL indeterminate;

/** The class to use for the progress view. Instances of this class must confrom to the MMProgressView protocol. When setting a custom value this value must be set before setting the indeterminate property to YES.
 
 Defaults to MMRadialProgressView
 */
@property (nonatomic, assign) Class progressViewClass;

/** The HUD's indeterminate activity indicator. */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;

/** The determinate progress state.
 
 The progress ranges from 0-1.
 */
@property (nonatomic, assign) CGFloat progress;

/** The loop duration to be used when displaying animationImages. */
@property (nonatomic, assign) CGFloat animationLoopDuration;

/** The delegate that certain actions will be sent to. */
@property (nonatomic, weak) id<MMHudDelegate> delegate;

/** A boolean flag that tells the system that it needs to re-calculate the layout.
 
 Automatically flagged to YES when content properties change (titleText, messageText, etc).
 */
@property (nonatomic, assign) BOOL needsUpdate;

/** The text which will display at the top of the HUD.
 
 Setting this property will not immediately draw text on the label, as the entire layout will be flagged as dirty and will need to be recalculated, after which this string will be applied to the titleLabel.
 */
@property (nonatomic, copy) NSString *titleText;

/** The text which will display at the bottom of the HUD.
 
 Setting this property will not immediately draw text on the label, as the entire layout will be flagged as dirty and will need to be recalculated, after which this string will be applied to the messageLabel.
 */
@property (nonatomic, copy) NSString *messageText;

/** The static image which will display in the middle of the HUD. */
@property (nonatomic, strong) UIImage *image;

/** An array of animated images that will display in the middle of the HUD. This takes precedence over image. 
 */
@property (nonatomic, copy) NSArray *animationImages;

//-----------------------------------------------
/** @name Layout */
//-----------------------------------------------

/** Builds or updates the HUD using the current properties.
 
 Calling buildHUDAnimated:NO is functionally the same as simply calling applyLayoutFrames:
 
 @param animated Flag to indicate whether or not the HUD should animate the frame changes.
 */
- (void)buildHUDAnimated:(BOOL)animated;

/** Re-calculates the layout frames for the current HUD's content.
 
 This pass does not apply any of the calculated frames, but stores the calculated frames in temporary variables.
 */
- (void)updateLayoutFrames;

/** Applies frames that were calculated in updateLayoutFrames. If the HUD's layout has been marked as dirty through needsUpdate, then updateLayoutFrames will be called before applying frames.
 */
- (void)applyLayoutFrames;

/** Calls an animation block to animate the changes made by calling applyLayoutFrames with an optional completion block;
 
 @warning If the layout has not been flagged as dirty, updateLayoutFrames will not automatically be called.  This method will simply apply layout frames already calculated and animate the changes (if any).
 
 @param animated Flag to indicate whether or not the HUD should animate the frame changes.
 @param updateCompletion Completion block that will execute when the animation has completed.
 */
- (void)updateAnimated:(BOOL)animated withCompletion:(void(^)(BOOL completed))updateCompletion;

//-----------------------------------------------
/** @name Updating Content */
//-----------------------------------------------

/** Sets the determinate progress percentage with an optional animated flag.  Calling setProgress:animated:NO is the same as calling setProgress:
 
 @warning progress is a CGFloat between 0.f and 1.f. Setting progress to a value greater than 1.f has no unintended side effects.
 
 @param progress Progress to set the determinate progress display at.
 @param animated Flag to indicate whether or not the progress should update animated.
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/** Updates the title of the HUD and optionally animates the change in frame between the old and new states.
 
 Message content is retained when using this method call.
 
 @param title The new title to display on the HUD.
 @param animated Flag to indicate whether or not the HUD should animate the frame changes.
 */
- (void)updateTitle:(NSString *)title animated:(BOOL)animated;

/** Updates the message of the HUD and optionally animates the change in frame between the old and new states.
 
 Title content is retained when using this method call.
 
 @param message The new message to display on the HUD.
 @param animated Flag to indicate whether or not the HUD should animate the frame changes.
 */
- (void)updateMessage:(NSString *)message animated:(BOOL)animated;

/** Updates both the title and message of the HUD and optionally animates the change in frame between the old and new states.
 
 @param title The new title to display on the HUD.
 @param message The new message to display on the HUD.
 @param animated Flag to indicate whether or not the HUD should animate the frame changes.
 */
- (void)updateTitle:(NSString *)title message:(NSString *)message animated:(BOOL)animated;

//-----------------------------------------------
/** @name Display */
//-----------------------------------------------

/** Resets all presentation elements (labels, image views, layer properties, etc.), as well as other properties that are unnecessary to be retained between the end of a dismiss call and a show call.
 */
- (void)prepareForReuse;

@end
