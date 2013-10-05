//
//  MMProgressHUDOverlayView.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 7/5/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMProgressHUD.h"

@interface MMProgressHUDOverlayView : UIView

/** The style of the overlay. */
@property (nonatomic) MMProgressHUDWindowOverlayMode overlayMode;

/** The color for the overlay. This color will be used in both the linear and gradient overlay modes. */
@property (nonatomic) CGColorRef overlayColor;

/** Init a new overlay view with the specified frame and overlayMode.
 
 @param frame The frame of the overlayView.
 @param overlayMode The style of the overlay.
 */
- (instancetype)initWithFrame:(CGRect)frame
                  overlayMode:(MMProgressHUDWindowOverlayMode)overlayMode;

@end
