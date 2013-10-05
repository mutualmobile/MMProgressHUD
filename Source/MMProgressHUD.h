//
//  MMProgressHUD.h
//  MMProgressHUD
//
//  Created by Lars Anderson on 10/7/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMHud.h"

extern NSString * const MMProgressHUDDefaultConfirmationMessage;

extern NSString * const MMProgressHUDAnimationShow;
extern NSString * const MMProgressHUDAnimationDismiss;
extern NSString * const MMProgressHUDAnimationWindowFadeOut;
extern NSString * const MMProgressHUDAnimationKeyShowAnimation;
extern NSString * const MMProgressHUDAnimationKeyDismissAnimation;

extern CGFloat const MMProgressHUDStandardDismissDelay;

@class MMProgressHUDWindow;
@class MMProgressHUDOverlayView;

typedef NS_ENUM(NSInteger, MMProgressHUDPresentationStyle){
    MMProgressHUDPresentationStyleDrop = 0, //default
    MMProgressHUDPresentationStyleExpand,
    MMProgressHUDPresentationStyleShrink,
    MMProgressHUDPresentationStyleSwingLeft,
    MMProgressHUDPresentationStyleSwingRight,
    MMProgressHUDPresentationStyleBalloon,
    MMProgressHUDPresentationStyleFade,
    MMProgressHUDPresentationStyleNone
};

typedef NS_ENUM(NSInteger, MMProgressHUDWindowOverlayMode){
    MMProgressHUDWindowOverlayModeNone = -1,
    MMProgressHUDWindowOverlayModeGradient = 0,
    MMProgressHUDWindowOverlayModeLinear,
    /*MMProgressHUDWindowOverlayModeBlur*/ //iOS 7 only
};

//iOS 7 only
//typedef NS_ENUM(NSInteger, MMProgressHUDOptions) {
//    MMProgressHUDOptionGravityEnabled = 1 << 0,
//    MMProgressHUDOptionGyroEnabled = 1 << 1,
//};

@interface MMProgressHUD : UIView

/** An enum to specify the style in which to display progress.
 
 The default style is indeterminate progress.
 
 @warning Deprecated: To use determinate progress, set a progressViewClass and call showDeterminateProgressWithTitle:status and friends. All other show methods default to indeterminate progress.
 */
@property (nonatomic, assign) MMProgressHUDProgressStyle progressStyle DEPRECATED_ATTRIBUTE;

/** The determinate progress state.
 
 The progress ranges from 0-1.
 */
@property (nonatomic, assign) CGFloat progress;

/** A Boolean value that indicates whether or not the HUD is visible. */
@property(nonatomic, readonly, getter = isVisible) BOOL visible;

/** A boolean value that indicates whether or not the HUD has been cancelled manually. */
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;

/** The presentation style for the HUD. 
 
 Persistent across show calls.
 */
@property(nonatomic, assign) MMProgressHUDPresentationStyle presentationStyle;

/** The glow color for the HUD.
 
 The glow color is used during confirmation of a user-cancelled action.
 */
@property(nonatomic, assign) CGColorRef glowColor;

/** The default confirmation message for user-confirmed cancellation.
 
This message will be presented to the user when a cancelBlock is present after the user taps on the screen while the HUD is presented.
*/
@property(nonatomic, copy) NSString *confirmationMessage;

/** The void block executed when the user confirms their intent to cancel an operation. */
@property(nonatomic, copy) void(^cancelBlock)(void);

/** The image to be used for the error state. Persistent across show calls.
 
 The image size is currently fixed to 100x100. The image will scale to fit if the image is larger than 100x100, otherwise it will remain centered.
 */
@property (nonatomic, strong) UIImage *errorImage;

/** The image to be used for the success state. Persistent across show calls.
 
 The image size is currently fixed to 100x100. The image will scale to fit if the image is larger than 100x100, otherwise it will remain centered.
 */
@property (nonatomic, strong) UIImage *successImage;

/** A block to be executed when the progress fed to the HUD reaches 100%.
 
 This block will also fire when the progress exceeds 100%. This block was designed to be used by setting up your completion call before calling show: on the HUD, then simply feed progress updates to the HUD via the updateProgress: methods. When progress reaches 100%, this block is automatically fired. This block is automatically released after firing and is guaranteed to only fire once.
 
 @warning If the HUD is not visible and any of the updateProgress methods are called with a progress of at least 100% (1.f), the progressCompletion block is not guaranteed to fire. For example, if you were to call updateProgress: with 100% progress without having previously presented the HUD, the HUD will be forced to manually display itself, which will not fire the progressCompletion block.
 */
@property (nonatomic, copy) void(^progressCompletion)(void);

/** A block to be executed as soon as the dismiss animation has completed and the HUD is offscreen.
 
 This block will be automatically released and nil'd after firing and is guaranteed to fire only once.
 */
@property (nonatomic, copy) void(^dismissAnimationCompletion)(void);

/** A block to be executed as soon as the show animation has completed and the HUD is fully on screen.
 
 This block will be automatically released and nil'd after firing and is guaranteed to fire only once.
 */
@property (nonatomic, copy) void(^showAnimationCompletion)(void);

/** The HUD that is displaying all information. */
@property (nonatomic, strong) MMHud *hud;

/** The overlay type for the view behind the HUD */
@property (nonatomic, assign) MMProgressHUDWindowOverlayMode overlayMode;

/** The overlay view that is placed just behind the HUD.
 */
@property (nonatomic, strong, readonly) MMProgressHUDOverlayView *overlayView;

/** The class to use for the progress view. Instances of this class must confrom to the MMProgressView protocol. When setting a custom value this value must be set before setting the indeterminate property to YES.
 
 Defaults to MMRadialProgressView
 */
@property (nonatomic, assign) Class progressViewClass;

#pragma mark - Instance Methods
- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

- (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status
                     confirmationMessage:(NSString *)confirmation
                             cancelBlock:(void (^)(void))cancelBlock
                                  images:(NSArray *)images;

- (void)updateProgress:(CGFloat)progress
            withStatus:(NSString *)status
                 title:(NSString *)title;

#pragma mark - Class Methods
/** Gives access to the shared instance of the HUD.
 
 @return Shared MMProgressHUD instance.
 */
+ (instancetype)sharedHUD;

@end

@interface MMProgressHUD (Class)

//-----------------------------------------------
/** @name Presentation */
//-----------------------------------------------

/** Shows indeterminate HUD.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 */
+ (void)show;


/** Shows indeterminate HUD with specified title.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 */
+ (void)showWithTitle:(NSString *)title;


/** Shows user-blocking HUD with only a status message.
 
 Since the title of this HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param status Status message to display.
 */
+ (void)showWithStatus:(NSString *)status;


/** Shows indeterminate HUD with specified title and status.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display. 
 */
+ (void)showWithTitle:(NSString *)title status:(NSString *)status;

/** Shows auto-confirming, cancellable HUD with specified confirmation message, cancel callback block, and animation images, in addition to title and status.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param confirmation Message to display to the user when the HUD is tapped to confirm that the user wants to cancel an action.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 @param images An array of images to be animated while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

/** Shows auto-confirming, cancellable HUD with specified confirmation message, cancel callback block, and static image, in addition to title and status.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param confirmation Message to display to the user when the HUD is tapped to confirm that the user wants to cancel an action.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 @param image The image to be used while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image;

/** Shows indeterminate, auto-confirming, cancellable HUD with specified confirmation message and cancel callback block.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param confirmation Message to display to the user when the HUD is tapped to confirm that the user wants to cancel an action.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock;

/** Shows auto-confirming, cancellable HUD with cancel callback block and animated images, using default system confirmation message.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 @param images An array of images to be animated while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

/** Shows auto-confirming, cancellable HUD with cancel callback block and static image, using default system confirmation message.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 @param image The image to be used while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image;

/** Shows indeterminate, auto-confirming, cancellable HUD with cancel callback block using default system confirmation message.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param cancelBlock Void block that will be called when the user successfully initiates a cancelled action.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock;

/** Shows user-blocking HUD with specified title, status message, and static image.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param image The image to be used while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
                image:(UIImage *)image;

/** Shows user-blocking HUD with specified title, status message, and animated images.
 
 When the title of the HUD is nil, the status message font will become bold by default.
 
 @warning All show methods are mutually exclusive of one another. Use the updateStatus: method to update the HUD's status while maintaining all previously set presentation attributes such as image, images, cancelBlock, title, or confirmationMessage. For example: calling showWithTitle:status: after calling showWithTitle:status:image: will wipe out the image specified in the latter call.
 
 @param title Title to display.
 @param status Status message to display.
 @param images An array of images to be animated while the HUD is displayed.
 */
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status 
               images:(NSArray *)images;

//-----------------------------------------------
/** @name Dismissal */
//-----------------------------------------------

/** Dismisses the shared HUD with the current presentationStyle and default delay. */
+ (void)dismiss;


/** Dismisses the shared HUD with the current presentationStyle and specified delay. 
 @param delay Delay to wait before animating the dismiss of the HUD.
 */
+ (void)dismissAfterDelay:(NSTimeInterval)delay;

#pragma mark - Dismiss with Error

/** Dismisses the shared HUD with the current presentationStyle in an error-state after a user-specified delay.
 
 @param message Error message to display to the user.
 @param title Error title to display to the user.
 @param delay Delay to wait before animating the dismiss of the HUD.
 */
+ (void)dismissWithError:(NSString *)message
                   title:(NSString *)title
              afterDelay:(NSTimeInterval)delay;

/** Dismisses the shared HUD with the current presentationStyle in an error-state after a standard delay.
 
 @param message Error message to display to the user.
 @param title Error title to display to the user.
 */
+ (void)dismissWithError:(NSString *)message
                   title:(NSString *)title;

/** Dismisses the shared HUD with the current presentationStyle in an error-state after a standard delay.
 
 @param message Error message to display to the user.
 */
+ (void)dismissWithError:(NSString *)message;

/** Dismisses the shared HUD with the current presentationStyle in an error-state after a user-specified delay.
 
 @param message Error message to display to the user.
 @param delay Delay to wait before animating the dismiss of the HUD.
 */
+ (void)dismissWithError:(NSString *)message
              afterDelay:(NSTimeInterval)delay;

#pragma mark - Dismiss with Success
/** Dismisses the shared HUD with the current presentationStyle in a success-state after a user-specified delay.
 
 @param message Success message to display to the user.
 @param title Success title to display to the user.
 @param delay Delay to wait before animating the dismiss of the HUD.
 */
+ (void)dismissWithSuccess:(NSString *)message
                     title:(NSString *)title
                afterDelay:(NSTimeInterval)delay;

/** Dismisses the shared HUD with the current presentationStyle in a success-state.
 
 @param message Success message to display to the user.
 @param title Success title to display to the user.
 */
+ (void)dismissWithSuccess:(NSString *)message 
                     title:(NSString *)title;

/** Dismisses the shared HUD with the current presentationStyle in an error-state.
 
 @param message Success message to display to the user.
 */
+ (void)dismissWithSuccess:(NSString *)message;

//-----------------------------------------------
/** @name Determinate Progress. */
//-----------------------------------------------

/** Sets a determinate progress class on the sharedHUD instance to be used with the `showDeterminateProgress` methods.
 
 @warning When progressClass is nil the progress will be indeterminate.
 
 @param progressClass A class that conforms to the MMProgressView protocol.
 */
+ (void)setProgressViewClass:(Class)progressClass;

/** Displays a determinate progress view.
 
 @warning When progressClass is nil the progress will be indeterminate.
 
 @param title The title to be displayed on the HUD
 @param status The status message to be displayed on the HUD
 */
+ (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status;

/** Displays a determinate progress view.
 
 @warning When progressClass is nil the progress will be indeterminate.
 
 @param title The title to be displayed on the HUD
 @param status The status message to be displayed on the HUD
 @param confirmation The confirmation message to be displayed when the user performs a single-tap on the hud.
 @param cancelBlock A block to be executed after the user has tapped the hud twice (once to prompt to confirm and a second to confirm the "cancellation").
 */
+ (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status
                     confirmationMessage:(NSString *)confirmation
                             cancelBlock:(void (^)(void))cancelBlock;

//-----------------------------------------------
/** @name Updating Content */
//-----------------------------------------------

/** Updates the currently-displaying HUD with specified status message.
 
 HUD will retain all previous attributes, such as title, image, etc.  Only the status message and HUD frame will change.
 
 @param status Status message to update the HUD with.
 */
+ (void)updateStatus:(NSString *)status;

/** Updates the currently-displaying HUD with specified status message.
 
 HUD will retain all previous attributes, such as title, image, etc.  Only the title and status message will change. Setting the title message to nil will be functionally identical to calling updateStatus:.
 
 @param title Title message to update the HUD with.
 @param status Status message to update the HUD with.
 */
+ (void)updateTitle:(NSString *)title status:(NSString *)status;

/** Updates the currently-displaying HUD with specified progress, status message, and title.
 
 HUD will retain all previous attributes, such as title, progressStyle, etc.  Only the title, status message, and progress will change. Setting the title message to nil will be functionally identical to calling updateStatus:.
 
 @param progress Progress percentage to update the HUD with.
 @param title Title message to update the HUD with.
 @param status Status message to update the HUD with.
 */
+ (void)updateProgress:(CGFloat)progress withStatus:(NSString *)status title:(NSString *)title;

/** Updates the currently-displaying HUD with specified progress, and status message.
 
 HUD will retain all previous attributes, such as title, progressStyle, etc.  Only the status message and progress will change.
 
 @param progress Progress percentage to update the HUD with.
 @param status Status message to update the HUD with.
 */
+ (void)updateProgress:(CGFloat)progress withStatus:(NSString *)status;

/** Updates the currently-displaying HUD with specified progress.
 
 HUD will retain all previous attributes, such as title, status, progressStyle, etc.  Only the progress will change.
 
 @param progress Progress percentage to update the HUD with.
 */
+ (void)updateProgress:(CGFloat)progress;

//-----------------------------------------------
/** @name Style & Presentation */
//-----------------------------------------------

/** Sets the style of the current shared instance.
 
 @param presentationStyle Animation style for the shared HUD to use.
 */
+ (void)setPresentationStyle:(MMProgressHUDPresentationStyle)presentationStyle;

/** Sets the style of the current shared instance.
 
 @param displayStyle Style to set the HUD to.
 */
+ (void)setDisplayStyle:(MMProgressHUDDisplayStyle)displayStyle;

@end

@interface MMProgressHUD (Deprecated)

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status DEPRECATED_ATTRIBUTE;

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                        image:(UIImage *)image DEPRECATED_ATTRIBUTE;

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                       images:(NSArray *)images DEPRECATED_ATTRIBUTE;

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock DEPRECATED_ATTRIBUTE;

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                        image:(UIImage *)image DEPRECATED_ATTRIBUTE;

/**
 The showProgressWithStyle: methods have been deprecated in favor of the new dynamic progress class support. Please specify a determinate progress class to use on MMProgressHUD by using setProgressViewClass:.
 
 @warning This method will be removed in some version in the future.
 */
+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                       images:(NSArray *)images DEPRECATED_ATTRIBUTE;

@end