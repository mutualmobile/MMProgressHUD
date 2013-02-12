//
//  MMRadialProgress.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 5/14/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMRadialProgressView : UIView

/** The percent of the pie that will be filled in. Valid values are between 0 and 1. (Animatable) */
@property (nonatomic) CGFloat progress;

/** Change the progress percent animated.
 
 @param progress The progress as a percent (0-1).
 @param animated A boolean to indicate whether to animate the change in progress animated.
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/** Change the progress percent animated with a completion block.
 
 @param progress The progress as a percent (0-1).
 @param animated A boolean to indicate whether to animate the change in progress animated.
 @param completion A block that will fire upon completion of animating the change in progress. The boolean sent with the block will indicate if the animation finished successfully.
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated withCompletion:(void(^)(BOOL completed))completion;

@end
