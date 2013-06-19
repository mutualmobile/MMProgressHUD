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

/** The window that was key at presentation time. Used to grab the view controller associated with the key window for rotation callbacks if they are available. */
@property (nonatomic, strong) UIWindow *oldWindow;

@end
