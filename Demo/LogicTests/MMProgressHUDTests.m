//
//  MMProgressHUDTests.m
//  MMProgressHUDTests
//
//  Created by Russell Wickliffe on 6/8/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "OCMock.h"

#import "MMHud.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDPrivate.h"
#import "MMVectorImage.h"

@interface MMProgressHUDTests : GHAsyncTestCase

@property (nonatomic, strong) MMProgressHUD *progressHUD;

@end

@implementation MMProgressHUDTests

- (BOOL)shouldRunOnMainThread{
    return YES;
}

- (void)setUp{
    [super setUp];
    
    _progressHUD = [[MMProgressHUD alloc] init];
}

- (void)tearDown{
    
    [_progressHUD forceCleanup];
    _progressHUD = nil;
    
    [super tearDown];
}

- (void)testInit{
    GHAssertNotNil(self.progressHUD, @"Progress hud should not be nil!");
}

- (void)testInitCreatesHUD{
    GHAssertNotNil(((MMProgressHUD*)self.progressHUD).hud, @"HUD is nil after init!");
}

- (void)testInitSetsSuccessImage{
    GHAssertNotNil(self.progressHUD.successImage, @"Success image is nil and shouldn't be!");
}

- (void)testInitSetsErrorImage{
    GHAssertNotNil(self.progressHUD.errorImage, @"Error image is nil and shouldn't be!");
}

- (void)testSharedInstanceNotNil{
    MMProgressHUD *shared = [MMProgressHUD sharedHUD];
    
    GHAssertNotNil(shared, @"Shared instance is nil!");
}

- (void)testSharedInstaceIsSingleton{
    MMProgressHUD *shared = [MMProgressHUD sharedHUD];
    MMProgressHUD *shared2 = [MMProgressHUD sharedHUD];
    
    GHAssertEquals(shared, shared2, @"Shared instances not same!");
}

- (void)testActivityIndicatorIsLargeWhite{
    NSInteger activityIndicatorStyle = self.progressHUD.hud.activityIndicator.activityIndicatorViewStyle;
    
    GHAssertTrue(activityIndicatorStyle == UIActivityIndicatorViewStyleWhiteLarge, @"Activity indicator style is not large white!");
}

- (void)testInitialDisplayStyleIsPlain{
    GHAssertTrue(self.progressHUD.hud.displayStyle == MMProgressHUDDisplayStylePlain,@"Initial display style is not plain!");
}

- (void)testChangeDisplayStyle{
    [self.progressHUD.hud setDisplayStyle:MMProgressHUDDisplayStyleBordered];
    
    GHAssertTrue(self.progressHUD.hud.displayStyle == MMProgressHUDDisplayStyleBordered, @"HUD style did not set!");
    
    self.progressHUD.hud.displayStyle = MMProgressHUDDisplayStylePlain;
    
    GHAssertTrue(self.progressHUD.hud.displayStyle == MMProgressHUDDisplayStylePlain, @"HUD style did not set!");
}

- (void)testProgressGetSet{
    CGFloat newProgress = 0.3f;
    self.progressHUD.progress = newProgress;
    GHAssertTrue(self.progressHUD.progress == newProgress, @"Progress did not update!");
}

- (void)testProgressCompletionBlockGetsSet{
    self.progressHUD.progressCompletion = ^{ /* stuff */ };
    
    GHAssertNotNil(self.progressHUD.progressCompletion, @"Progress completion block not set!");
}

- (void)testProgressCompletionBlockReleasesItselfAfterExecution{
    self.progressHUD.progressCompletion = ^{ /* stuff */ };
    
    self.progressHUD.progressCompletion();
    
    GHAssertNil(self.progressHUD.progressCompletion, @"Progress completion block didn't release itself!");
}

#pragma mark - Images
- (void)testShowImageActuallySetsImage{
    UIImage *image = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeX size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    
    id mockHUD = [OCMockObject partialMockForObject:self.progressHUD];
    
    [mockHUD showWithTitle:@"title" status:@"status" confirmationMessage:nil cancelBlock:nil images:@[image]];

    UIImage *testImage = self.progressHUD.hud.image;
    
    [self.progressHUD dismissWithCompletionState:MMProgressHUDCompletionStateNone title:@"hello!" status:@"i'm done!" afterDelay:0.f];
    
    GHAssertNotNil(testImage, @"Image is nil after calling show: with an image!");
}

- (void)testShowImageDoesNotSetAnimatedImages{
    UIImage *image = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeCheck size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    
    [self.progressHUD showWithTitle:@"title" status:@"status" confirmationMessage:nil cancelBlock:nil images:@[image]];
    
    NSArray *testImages = self.progressHUD.hud.animationImages;
    
    [self.progressHUD dismissWithCompletionState:MMProgressHUDCompletionStateNone title:@"hello!" status:@"i'm done!" afterDelay:0.f];
    
    GHAssertTrue(testImages.count == 0, @"Animated images are nil after calling show: with an array of animated images!");
}

- (void)testShowAnimatedImagesActuallySetsAnimatedImages{
    
    UIImage *image = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeCheck size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    UIImage *image2 = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeX size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    
    [self.progressHUD showWithTitle:@"title" status:@"status" confirmationMessage:nil cancelBlock:nil images:@[image, image2]];
    
    NSArray *testImages = self.progressHUD.hud.animationImages;
    
    [self.progressHUD dismissWithCompletionState:MMProgressHUDCompletionStateNone title:@"hello!" status:@"i'm done!" afterDelay:0.f];
    
    GHAssertTrue(testImages.count == 2, @"Animated images are nil after calling show: with an array of animated images!");
}

- (void)testShowAnimatedImagesDoesNotSetStaticImage{
    
    UIImage *image = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeCheck size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    UIImage *image2 = [MMVectorImage vectorImageShapeOfType:MMVectorShapeTypeX size:CGSizeMake(10, 10) fillColor:[UIColor redColor]];
    
    [self.progressHUD showWithTitle:@"title" status:@"status" confirmationMessage:nil cancelBlock:nil images:@[image, image2]];
    
    UIImage *testImage = self.progressHUD.hud.image;
    
    [self.progressHUD dismissWithCompletionState:MMProgressHUDCompletionStateNone title:@"hello!" status:@"i'm done!" afterDelay:0.f];
    
    GHAssertNil(testImage, @"Image is not nil after calling show: with an animated image set!");
}

#pragma mark - Glow Color/Animation
- (void)testDefaultGlowColorIsSet{
    GHAssertTrue(self.progressHUD.glowColor != NULL, @"Default glow color is NULL!");
}

- (void)testSetGlowColorSetsGlowColor{
    CGColorRef blueColor = CGColorRetain([UIColor blueColor].CGColor);
    CGColorRef newColor = blueColor;
    CGColorRelease(blueColor);
    
    GHAssertNotEquals(self.progressHUD.glowColor, newColor, @"Default color mysteriously matches new color!");
    
    self.progressHUD.glowColor = newColor;
    
    GHAssertEquals(self.progressHUD.glowColor, newColor, @"New glow color does not get properly set!");
}

- (void)testGlowAnimationGroupNotNil{
    GHAssertNotNil([self.progressHUD _glowAnimation],@"Glow animation is nil!");
}

- (void)testGlowAnimationGroupContainsProperSubAnimations{
    CAAnimationGroup *glowAnimation = [self.progressHUD _glowAnimation];
    
    int animationCount = glowAnimation.animations.count;
    int validNumerOfAnimations = 3;
    
    GHAssertTrue(animationCount == validNumerOfAnimations, @"Number of animations for glow should be %i, is %i", validNumerOfAnimations, animationCount);
}

- (void)testGlowAnimationGroupGetsAdded{
    [self.progressHUD _beginGlowAnimation];
    
    GHAssertNotNil([self.progressHUD.hud.layer animationForKey:@"glow-animation"], @"Glow animation did not get properly added to hud layer!");
}

#pragma mark - Tap Handling
- (void)testTapHandlerStartsGlowAnimation{
    self.progressHUD.cancelBlock = ^{ /* stuff */ };
    
    [self.progressHUD _handleTap:nil];
    
    GHAssertNotNil([self.progressHUD.hud.layer animationForKey:@"glow-animation"], @"Glow animation does not get added to hud layer on cancel confirmation tap!");
}

- (void)testTapHandlerConfirmedTapDismisses{
    id mockProgressHUD = [OCMockObject partialMockForObject:self.progressHUD];
    
    self.progressHUD.cancelBlock = ^{ /* stuff */ };
    
    NSLog(@"progressHUD: %@", self.progressHUD);
    
    [self.progressHUD setDismissAnimationCompletion:^{ /* do stuff */ }];
    
    [mockProgressHUD _handleTap:nil];
    
    [[mockProgressHUD expect] dismiss];
    
    [mockProgressHUD _handleTap:nil];
    
    [self runForInterval:1];
        
    [mockProgressHUD verify];
}

- (void)testTapHandlerUpdatesContentProperlyOnConfirmation{
    self.progressHUD.cancelBlock = ^{ /* stuff */ }; //initiates a confirmation
    NSString *confirmThis = @"confirm_this!";
    self.progressHUD.confirmationMessage = confirmThis;
    
    [self.progressHUD _handleTap:nil];
    
    GHAssertEqualStrings(self.progressHUD.hud.statusLabel.text, confirmThis, @"Tap confirmation did not update HUD message!");
}

- (void)testTapHandlerOnlyUpdatesMessageContentOnConfirmation{
    self.progressHUD.cancelBlock = ^{ /* stuff */ }; //initiates a confirmation
    
    NSString *oldTitle = @"old_title!";
    self.progressHUD.title = oldTitle;
    
    [self.progressHUD _handleTap:nil];
    
    GHAssertEqualStrings(self.progressHUD.hud.titleText, oldTitle, @"Tap confirmation changed title string!");
}

- (void)testTapHandlerDoesNotActivateWithNilCancelBlock{
    id mockProgressHUD = [OCMockObject mockForClass:self.progressHUD.class];
    
    [[mockProgressHUD expect] _handleTap:nil];
    
    [mockProgressHUD _handleTap:nil];
    
    [mockProgressHUD verify];
}

#pragma mark - Passthrough Properties
- (void)testSetTitleUpdateHUDTitleProperty{
    
    NSString *newTitle = @"new_title";
    self.progressHUD.title = newTitle;
    
    GHAssertEqualStrings(self.progressHUD.hud.titleText, newTitle, @"%@ property did not update %@ title property!", self.progressHUD.class, self.progressHUD.hud.class);
}

- (void)testSetMessageUpdatesHUDMessageProperty{
    NSString *newMessage = @"new_message";
    self.progressHUD.status = newMessage;
    
    GHAssertEqualStrings(self.progressHUD.hud.messageText, newMessage,@"%@ property did not update %@ message property!", self.progressHUD.class, self.progressHUD.hud.class);
}

#pragma mark - MMHud Delegate
- (void)testInitSetsHUDDelegate{
    GHAssertNotNil(self.progressHUD.hud.delegate, @"Delegate is nil!");
}

- (void)testDelegateRespondsToCompletionStateMethod{
    GHAssertTrue([self.progressHUD.hud.delegate respondsToSelector:@selector(hud:imageForCompletionState:)], @"Delegate does not respond to hud:imageForCompletionState!");
}

- (void)testDelegateRespondsToCenterPointMethod{
    GHAssertTrue([self.progressHUD.hud.delegate respondsToSelector:@selector(hudCenterPointForDisplay:)], @"Delegate does not respond to hudCenterPointForDisplay!");
}

- (void)testDelegateRespondsToProgressCompletionMethod{
    GHAssertTrue([self.progressHUD.hud.delegate respondsToSelector:@selector(hudDidCompleteProgress:)], @"Delegate does not respond to progress completion (hudDidCompleteProgress:)!");
}

- (void)testDelegateReturnsNonNilImageForSuccessCompletionState{
    UIImage *success = [self.progressHUD hud:self.progressHUD.hud imageForCompletionState:MMProgressHUDCompletionStateSuccess];
    
    GHAssertNotNil(success, @"Success image was nil from delegate method!");
}

- (void)testDelegateReturnsCorrectImageForSuccessCompletionState{
    UIImage *success = [self.progressHUD hud:self.progressHUD.hud imageForCompletionState:MMProgressHUDCompletionStateSuccess];
    
    GHAssertEquals(success, self.progressHUD.successImage, @"Success image returned by delegate method is not the same as the instance image!");
}

- (void)testDelegateReturnsNonNilImageForErrorCompletionState{
    UIImage *success = [self.progressHUD hud:self.progressHUD.hud imageForCompletionState:MMProgressHUDCompletionStateError];
    
    GHAssertNotNil(success, @"Success image was nil from delegate method!");
}

- (void)testDelegateReturnsCorrectImageForErrorCompletionState{
    UIImage *success = [self.progressHUD hud:self.progressHUD.hud imageForCompletionState:MMProgressHUDCompletionStateError];
    
    GHAssertEquals(success, self.progressHUD.errorImage, @"Success image returned by delegate method is not the same as the instance image!");
}

#pragma mark - Overlay Testing
- (void)testOverlayViewGetsCreated{
    [self.progressHUD _buildOverlayViewForMode:self.progressHUD.overlayMode inView:self.progressHUD];
    
    GHAssertNotNil(self.progressHUD.overlayView, @"Overlay view is nil after creation!");
}

- (void)testOverlayModeIsCorrectOnCreation{
    MMProgressHUDWindowOverlayMode mode = MMProgressHUDWindowOverlayModeLinear;
    
    [self.progressHUD _buildOverlayViewForMode:mode inView:self.progressHUD];
    
    GHAssertTrue(self.progressHUD.overlayView.overlayMode == mode, @"Overlay mode did not correctly get set!");
}

- (void)testOverlayViewIsInsertedAtBottomOfViewHeirarchy{
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
    
    [self.progressHUD addSubview:newView];
    
    
    [self.progressHUD _buildOverlayViewForMode:self.progressHUD.overlayMode inView:self.progressHUD];
    
    GHAssertEquals([(self.progressHUD.subviews)[0] class], [MMProgressHUDOverlayView class] ,@"Overlay view was not inserted at bottom of view heirarchy!");
}

- (void)testBuildWindowBuildsOverlayMode{
    id mockHUD = [OCMockObject partialMockForObject:self.progressHUD];
    
    [[mockHUD expect] _buildOverlayViewForMode:self.progressHUD.overlayMode inView:OCMOCK_ANY];
    
    [mockHUD _buildHUDWindow];
    
    [mockHUD verify];
}

@end
