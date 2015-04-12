//
//  MMProgressHUD+Class.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 7/2/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMProgressHUD.h"

@interface MMProgressHUD()

- (CGPoint)_windowCenterForHUDAnchor:(CGPoint)anchor;
- (void)dismissWithCompletionState:(MMProgressHUDCompletionState)completionState
                             title:(NSString *)title
                            status:(NSString *)status
                        afterDelay:(NSTimeInterval)delay;

- (void)_updateHUDAnimated:(BOOL)animated
    withCompletion:(void(^)(BOOL completed))completionBlock;

- (void)show;
- (void)dismiss;
- (void)dismissAfterDelay:(NSTimeInterval)delay;

@end

@implementation MMProgressHUD (Class)

//class setters
+ (void)setPresentationStyle:(MMProgressHUDPresentationStyle)animationStyle {
    [[MMProgressHUD sharedHUD] setPresentationStyle:animationStyle];
}

+ (void)setDisplayStyle:(MMProgressHUDDisplayStyle)style {
    MMHud *hud = [[MMProgressHUD sharedHUD] hud];
    [hud setDisplayStyle:style];
}

+ (void)setSpinAnimationImages:(NSArray *)animationImages {
    [[MMProgressHUD sharedHUD] setSpinAnimationImages:animationImages];
}

//updates
+ (void)updateStatus:(NSString *)status {
    [MMProgressHUD updateTitle:nil status:status]; 
}

+ (void)updateTitle:(NSString *)title status:(NSString *)status {
    MMProgressHUD *hud = [MMProgressHUD sharedHUD];
    
    NSArray *images = nil;
    if (hud.hud.animationImages.count > 0) {
        images = hud.hud.animationImages;
    }
    else if (hud.hud.image != nil) {
        images = @[hud.hud.image];
    }
    
    if (title == nil) {
        title = hud.hud.titleText;
    }
    
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:hud.confirmationMessage
                     cancelBlock:hud.cancelBlock
                          images:images];
}

+ (void)setProgressViewClass:(Class)progressClass{
    [[MMProgressHUD sharedHUD] setProgressViewClass:progressClass];
}

//with progress
+ (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status {
    [MMProgressHUD showDeterminateProgressWithTitle:title
                                             status:status
                                confirmationMessage:nil
                                        cancelBlock:nil];
}

+ (void)showDeterminateProgressWithTitle:(NSString *)title
                                  status:(NSString *)status
                     confirmationMessage:(NSString *)confirmation
                             cancelBlock:(void (^)(void))cancelBlock {
    [[MMProgressHUD sharedHUD] showDeterminateProgressWithTitle:title
                                                         status:status
                                            confirmationMessage:confirmation
                                                    cancelBlock:cancelBlock
                                                         images:nil];
}

+ (void)updateProgress:(CGFloat)progress
            withStatus:(NSString *)status
                 title:(NSString *)title {
    [[MMProgressHUD sharedHUD] updateProgress:progress
                                   withStatus:status
                                        title:title];
}

+ (void)updateProgress:(CGFloat)progress 
            withStatus:(NSString *)status {
    [MMProgressHUD updateProgress:progress
                       withStatus:status
                            title:nil];
}

+ (void)updateProgress:(CGFloat)progress {
    [MMProgressHUD updateProgress:progress
                       withStatus:nil
                            title:nil];
}

//indeterminate status

+ (void)show {
    [MMProgressHUD showWithTitle:nil status:nil];
}

+ (void)showWithTitle:(NSString *)title {
    [MMProgressHUD showWithTitle:title
                          status:nil];
}

+ (void)showWithStatus:(NSString *)status {
    [MMProgressHUD showWithTitle:nil
                          status:status];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status {
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:nil];
}

+ (void)showWithTitle:(NSString *)title 
               status:(NSString *)status 
                image:(UIImage *)image {
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                           image:image];
}

+ (void)showWithTitle:(NSString *)title 
               status:(NSString *)status
               images:(NSArray *)images {
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock {
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:nil];
}

//cancellation
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image {
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:(image != nil ? @[image] : nil)];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock 
               images:(NSArray *)images {
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:nil
                     cancelBlock:cancelBlock
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancel {
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:confirmation
                     cancelBlock:cancel
                          images:nil];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image {
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:confirmation
                     cancelBlock:cancelBlock
                          images:image ? @[image] : nil];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images {
    [[[MMProgressHUD sharedHUD] hud] setIndeterminate:YES];
    
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] showWithTitle:title
                                              status:status
                                 confirmationMessage:confirmation
                                         cancelBlock:cancelBlock
                                              images:images];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] showWithTitle:title
                                          status:status
                             confirmationMessage:confirmation
                                     cancelBlock:cancelBlock
                                          images:images];
    }
}

//dismissal
+ (void)dismissWithError:(NSString *)status
                   title:(NSString *)title 
              afterDelay:(NSTimeInterval)delay {
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithError:(NSString *)status
                   title:(NSString *)title {
    [MMProgressHUD dismissWithError:status
                              title:title
                         afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithError:(NSString *)status {
    [MMProgressHUD dismissWithError:status
                              title:nil];
}

+ (void)dismissWithError:(NSString *)status
              afterDelay:(NSTimeInterval)delay {
    [MMProgressHUD dismissWithError:status
                              title:nil
                         afterDelay:delay];
}

+ (void)dismissWithSuccess:(NSString *)status 
                     title:(NSString *)title 
                afterDelay:(NSTimeInterval)delay {
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithSuccess:(NSString *)status
                     title:(NSString *)title {
    [MMProgressHUD dismissWithSuccess:status
                                title:title
                           afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithSuccess:(NSString *)status {
    [MMProgressHUD dismissWithSuccess:status
                                title:nil];
}

+ (void)dismissAfterDelay:(NSTimeInterval)delay {
    [[MMProgressHUD sharedHUD] dismissAfterDelay:delay];
}

+ (void)dismiss {
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismiss];
        });
    }
    else {
        [[MMProgressHUD sharedHUD] dismiss];
    }
}

@end

@implementation MMProgressHUD (Deprecated)

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                        image:(UIImage *)image{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:image ? @[image] : nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
                       images:(NSArray *)images{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:nil
                             cancelBlock:nil
                                  images:images];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:confirmation
                             cancelBlock:cancelBlock
                                  images:nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                        image:(UIImage *)image{
    [MMProgressHUD showProgressWithStyle:progressStyle
                                   title:title
                                  status:status
                     confirmationMessage:confirmation
                             cancelBlock:cancelBlock
                                  images:image ? @[image] : nil];
}

+ (void)showProgressWithStyle:(MMProgressHUDProgressStyle)progressStyle
                        title:(NSString *)title
                       status:(NSString *)status
          confirmationMessage:(NSString *)confirmation
                  cancelBlock:(void (^)(void))cancelBlock
                       images:(NSArray *)images{
    [[MMProgressHUD sharedHUD] setProgressStyle:progressStyle];
    [[MMProgressHUD sharedHUD] showWithTitle:title
                                      status:status
                         confirmationMessage:confirmation
                                 cancelBlock:cancelBlock
                                      images:images];
}


@end
