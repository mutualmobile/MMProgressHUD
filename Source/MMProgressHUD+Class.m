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
                        afterDelay:(float)delay;

- (void)_updateHUDAnimated:(BOOL)animated
    withCompletion:(void(^)(BOOL completed))completionBlock;

- (void)show;
- (void)dismiss;

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmationMessage
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;

@end

@implementation MMProgressHUD (Class)

//class setters
+ (void)setPresentationStyle:(MMProgressHUDPresentationStyle)animationStyle{
    [[MMProgressHUD sharedHUD] setPresentationStyle:animationStyle];
}

+ (void)setDisplayStyle:(MMProgressHUDDisplayStyle)style{
    MMHud *hud = [[MMProgressHUD sharedHUD] hud];
    [hud setDisplayStyle:style];
}

//updates
+ (void)updateStatus:(NSString *)status{
    [MMProgressHUD updateTitle:nil status:status]; 
}

+ (void)updateTitle:(NSString *)title status:(NSString *)status{
    MMProgressHUD *hud = [MMProgressHUD sharedHUD];
    
    NSArray *images = nil;
    if (hud.hud.animationImages.count > 0) {
        images = hud.hud.animationImages;
    }
    else if(hud.hud.image != nil){
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

//with progress
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
                                  images:@[image]];
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
                                  images:@[image]];
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

+ (void)updateProgress:(CGFloat)progress withStatus:(NSString *)status title:(NSString *)title{
    MMProgressHUD *hud = [MMProgressHUD sharedHUD];
    [hud setProgress:progress];
    
    if (status != nil) {
        hud.hud.messageText = status;
    }
    
    if(title != nil){
        hud.hud.titleText = title;
    }
    
    if (hud.isVisible &&
        (hud.window != nil)) {
        
        void(^animationCompletion)(BOOL completed) = ^(BOOL completed){
            if (progress >= 1.f &&
                hud.progressCompletion != nil) {
                double delayInSeconds = 0.33f;//allow enough time for progress to animate
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    hud.progressCompletion();
                });
            }
        };
        
        [hud _updateHUDAnimated:YES
                 withCompletion:animationCompletion];
    }
    else{
        [hud show];
    }
}

+ (void)updateProgress:(CGFloat)progress 
            withStatus:(NSString *)status{
    [MMProgressHUD updateProgress:progress
                       withStatus:status
                            title:nil];
}

+ (void)updateProgress:(CGFloat)progress{
    [MMProgressHUD updateProgress:progress
                       withStatus:nil
                            title:nil];
}

//indeterminate status
+ (void)showWithStatus:(NSString *)status{
    [MMProgressHUD showWithTitle:nil
                          status:status];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:nil];
}

+ (void)showWithTitle:(NSString *)title 
               status:(NSString *)status 
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                           image:image];
}

+ (void)showWithTitle:(NSString *)title 
               status:(NSString *)status
               images:(NSArray *)images{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:nil
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:nil];
}

//cancellation
+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
                     cancelBlock:cancelBlock
                          images:@[image]];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock 
               images:(NSArray *)images{
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:nil
                     cancelBlock:cancelBlock
                          images:images];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancel{
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
                image:(UIImage *)image{
    [MMProgressHUD showWithTitle:title
                          status:status
             confirmationMessage:confirmation
                     cancelBlock:cancelBlock
                          images:@[image]];
}

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images{
    [[MMProgressHUD sharedHUD] setProgressStyle:MMProgressHUDProgressStyleIndeterminate];
    
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
              afterDelay:(float)delay{
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else{
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateError
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithError:(NSString *)status
                   title:(NSString *)title{
    [MMProgressHUD dismissWithError:status
                              title:title
                         afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithError:(NSString *)status{
    [MMProgressHUD dismissWithError:status
                              title:nil];
}

+ (void)dismissWithError:(NSString *)status
              afterDelay:(float)delay{
    [MMProgressHUD dismissWithError:status
                              title:nil
                         afterDelay:delay];
}

+ (void)dismissWithSuccess:(NSString *)status 
                     title:(NSString *)title 
                afterDelay:(float)delay{
    if ([NSThread isMainThread] == NO) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                            title:title
                                                           status:status
                                                       afterDelay:delay];
        });
    }
    else{
        [[MMProgressHUD sharedHUD] dismissWithCompletionState:MMProgressHUDCompletionStateSuccess
                                                        title:title
                                                       status:status
                                                   afterDelay:delay];
    }
}

+ (void)dismissWithSuccess:(NSString *)status
                     title:(NSString *)title{
    [MMProgressHUD dismissWithSuccess:status
                                title:title
                           afterDelay:MMProgressHUDStandardDismissDelay];
}

+ (void)dismissWithSuccess:(NSString *)status{
    [MMProgressHUD dismissWithSuccess:status
                                title:nil];
}

+ (void)dismiss{
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
