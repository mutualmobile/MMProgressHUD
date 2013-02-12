//
//  MMProgressHUDWindow.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMProgressHUD.h"

@interface MMProgressHUDWindow : UIWindow

/** The window that was key before making this window (self) key. This property will be set as the keyWindow when resignKeyWindow is called on this instance. */
@property (nonatomic, strong) UIWindow *oldWindow;

/** A set of classes that indicates additional user-subclasses of UIWindow should be excluded from the window-check when determining which window should be set back to key upon dismissing and cleaning up of MMProgressHUDWindow
 */
@property (strong, nonatomic) NSMutableSet *windowExclusionClasses;

@end
