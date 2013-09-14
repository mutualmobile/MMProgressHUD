//
//  MMProgressHUDDefines-Private.m
//  MMProgressHUDDemo
//
//  Created by Jonas Gessner on 25.08.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "MMProgressHUDDefines-Private.h"


BOOL const kMMProgressHUDDebugMode = NO;

NSString * const MMProgressHUDDefaultConfirmationMessage = @"Cancel?";
NSString * const MMProgressHUDAnimationShow = @"mm-progress-hud-present-animation";
NSString * const MMProgressHUDAnimationDismiss = @"mm-progress-hud-dismiss-animation";
NSString * const MMProgressHUDAnimationWindowFadeOut = @"mm-progress-hud-window-fade-out";
NSString * const MMProgressHUDAnimationKeyShowAnimation = @"show";
NSString * const MMProgressHUDAnimationKeyDismissAnimation = @"dismiss";


NSUInteger const MMProgressHUDConfirmationPulseCount = 8;//Keep this number even

NSTimeInterval const MMProgressHUDStandardDismissDelay = 0.75;

CGSize const MMProgressHUDDefaultImageSize = {37.f, 37.f};


CGFloat    const MMProgressHUDDefaultFontSize           = 16.f;

CGFloat    const MMProgressHUDMaximumWidth              = 300.f;
CGFloat    const MMProgressHUDMinimumWidth              = 100.f;
CGFloat    const MMProgressHUDContentPadding            = 5.f;
CGSize const MMProgressHUDDefaultContentAreaSize = { 100.f, 100.f };
CGSize const MMProgressHUDProgressContentAreaSize = { 40.f, 40.f };
CGSize const MMProgressHUDProgressMaximumAreaSize = {200.0f, 200.0f};


NSString * const MMProgressHUDFontNameBold = @"HelveticaNeue-Bold";
NSString * const MMProgressHUDFontNameNormal = @"HelveticaNeue-Light";


#ifdef DEBUG
#ifdef MM_HUD_FRAME_DEBUG
BOOL const MMProgressHUDFrameDebugModeEnabled;
#else
BOOL const MMProgressHUDFrameDebugModeEnabled;
#endif
#else
BOOL const MMProgressHUDFrameDebugModeEnabled;
#endif