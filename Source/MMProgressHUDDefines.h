//
//  MMProgressHUDDefines.h
//  MMProgressHUDDemo
//
//  Created by Jonas Gessner on 22.08.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

typedef NS_ENUM(NSInteger, MMProgressHUDPresentationStyle) {
    MMProgressHUDPresentationStyleDrop = 0, //default
    MMProgressHUDPresentationStyleExpand,
    MMProgressHUDPresentationStyleShrink,
    MMProgressHUDPresentationStyleSwingLeft,
    MMProgressHUDPresentationStyleSwingRight,
    MMProgressHUDPresentationStyleBalloon,
    MMProgressHUDPresentationStyleFade,
    MMProgressHUDPresentationStyleNone
};

typedef NS_ENUM(NSInteger, MMProgressHUDWindowOverlayMode) {
    MMProgressHUDWindowOverlayModeNone = -1,
    MMProgressHUDWindowOverlayModeGradient = 0,
    MMProgressHUDWindowOverlayModeLinear,
    /*MMProgressHUDWindowOverlayModeBlur*/ //iOS 7 only
};

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

//iOS 7 only
//typedef NS_ENUM(NSInteger, MMProgressHUDOptions) {
//    MMProgressHUDOptionGravityEnabled = 1 << 0,
//    MMProgressHUDOptionGyroEnabled = 1 << 1,
//};

#ifdef __cplusplus
#define MMExtern extern "C"
#else
#define MMExtern extern
#endif

MMExtern NSTimeInterval    const MMProgressHUDAnimateInDurationLong;
MMExtern NSTimeInterval    const MMProgressHUDAnimateInDurationMedium;
MMExtern NSTimeInterval    const MMProgressHUDAnimateInDurationNormal;
MMExtern NSTimeInterval    const MMProgressHUDAnimateInDurationShort;
MMExtern NSTimeInterval    const MMProgressHUDAnimateInDurationVeryShort;

MMExtern NSTimeInterval    const MMProgressHUDAnimateOutDurationLong;
MMExtern NSTimeInterval    const MMProgressHUDAnimateOutDurationMedium;
MMExtern NSTimeInterval    const MMProgressHUDAnimateOutDurationShort;


