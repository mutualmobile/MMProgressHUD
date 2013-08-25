//
//  MMProgressHUDDefines-Private.h
//  MMProgressHUDDemo
//
//  Created by Jonas Gessner on 25.08.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error MMProgressHUD uses APIs only available in iOS 5.0+
#endif


#import "MMProgressHUDDefines.h"

#ifdef DEBUG
#ifdef MM_HUD_DEBUG
#define MMHudLog(fmt, ...) NSLog((@"%@ [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)
#else
#define MMHudLog(...)
#endif
#else
#define MMHudLog(...)
#endif

#define MMHudWLog(fmt, ...) NSLog((@"%@ WARNING [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)


MMExtern BOOL const kMMProgressHUDDebugMode;

MMExtern NSString * const MMProgressHUDDefaultConfirmationMessage;
MMExtern NSString * const MMProgressHUDAnimationShow;
MMExtern NSString * const MMProgressHUDAnimationDismiss;
MMExtern NSString * const MMProgressHUDAnimationWindowFadeOut;
MMExtern NSString * const MMProgressHUDAnimationKeyShowAnimation;
MMExtern NSString * const MMProgressHUDAnimationKeyDismissAnimation;

MMExtern NSUInteger const MMProgressHUDConfirmationPulseCount;//Keep this number even

MMExtern NSTimeInterval const MMProgressHUDStandardDismissDelay;

MMExtern CGSize const MMProgressHUDDefaultImageSize;


MMExtern CGFloat    const MMProgressHUDDefaultFontSize;

MMExtern CGFloat    const MMProgressHUDMaximumWidth;
MMExtern CGFloat    const MMProgressHUDMinimumWidth;
MMExtern CGFloat    const MMProgressHUDContentPadding;
MMExtern CGSize const MMProgressHUDDefaultContentAreaSize;
MMExtern CGSize const MMProgressHUDProgressContentAreaSize;
MMExtern CGSize const MMProgressHUDProgressMaximumAreaSize;

MMExtern NSString * const MMProgressHUDFontNameBold;
MMExtern NSString * const MMProgressHUDFontNameNormal;

#ifdef DEBUG
#ifdef MM_HUD_FRAME_DEBUG
MMExtern BOOL const MMProgressHUDFrameDebugModeEnabled;
#else
MMExtern BOOL const MMProgressHUDFrameDebugModeEnabled;
#endif
#else
MMExtern BOOL const MMProgressHUDFrameDebugModeEnabled;
#endif

