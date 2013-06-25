//
//  MMHudTests.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 6/28/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "OCMock.h"

#import "MMHud.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDPrivate.h"

@interface MMHudTests : GHAsyncTestCase

@property (nonatomic, strong) MMHud *hud;
@property (nonatomic, strong) MMProgressHUD *progressHUD;

@end

@implementation MMHudTests

- (void)setUp{
    [super setUp];
    
    _hud = [[MMHud alloc] init];
    _progressHUD = [[MMProgressHUD alloc] init];
    _hud.delegate = _progressHUD;
}

- (void)tearDown{
    _hud.delegate = nil;
    _hud = nil;
    _progressHUD = nil;
    
    [super tearDown];
}

- (void)testInitNotNil{
    GHAssertNotNil(self.hud, @"Hud is nil after init!");
}

- (void)testTitleLabelIsNotNilAfterInit{
    GHAssertNotNil(self.hud.titleLabel, @"Text label is nil!");
}

- (void)testImageViewNotNilAfterInit{
    GHAssertNotNil(self.hud.imageView, @"imageView is nil!");
}

- (void)testBuildTitleLabelWorks{
    [self.hud _buildTitleLabel];
    
    GHAssertNotNil(self.hud.titleLabel, @"Title label is nil after creation!");
}

- (void)testBuildStatusLabelWorks{
    [self.hud _buildStatusLabel];
    
    GHAssertNotNil(self.hud.statusLabel, @"Status label is nil after creation!");
}

- (void)testNeedsUpdateIsYesAfterInit{
    GHAssertTrue(self.hud.needsUpdate, @"Needs update is NO after init!");
}

- (void)testUpdateTitleAndMessageChangesText{
    NSString *testTitle = @"test_title";
    NSString *testMessage = @"test_message";
    
    [self.hud updateTitle:testTitle message:testMessage animated:NO];
    
    GHAssertEqualStrings(testTitle, self.hud.titleText, @"Titles do not match after update!");
    GHAssertEqualStrings(testMessage, self.hud.messageText, @"Messages do not match after update!");
}

- (void)testUpdateTitleAndMessageChangesTextLabels{
    NSString *testTitle = @"test_title";
    NSString *testMessage = @"test_message";
    
    [self.hud updateTitle:testTitle message:testMessage animated:NO];
    
    GHAssertEqualStrings(testTitle, self.hud.titleLabel.text, @"Titles do not match after update!");
    GHAssertEqualStrings(testMessage, self.hud.statusLabel.text, @"Messages do not match after update!");
}

- (void)testUpdateTitleOnlyChangesTitleText{
    NSString *testTitle = @"test_title";
    NSString *messageBeforeUpdate = self.hud.statusLabel.text;
    
    [self.hud updateTitle:testTitle animated:NO];
    
    GHAssertEqualStrings(testTitle, self.hud.titleText, @"Titles do not match after update!");
    GHAssertEqualStrings(messageBeforeUpdate, self.hud.messageText, @"Message was changed when it wasn't supposed to!");
}

- (void)testUpdateTitleOnlyChangesTitleTextLabel{
    NSString *testTitle = @"test_title";
    NSString *messageBeforeUpdate = self.hud.messageText;
    
    [self.hud updateTitle:testTitle animated:NO];
    
    GHAssertEqualStrings(testTitle, self.hud.titleLabel.text, @"Titles do not match after update!");
    GHAssertEqualStrings(messageBeforeUpdate, self.hud.statusLabel.text, @"Message was changed when it wasn't supposed to!");
}

- (void)testNeedsLayoutCallsUpdateLayoutFramesOnApplyLayout{
    id mockHUD = [OCMockObject partialMockForObject:self.hud];
    
    [mockHUD setNeedsUpdate:YES];
    [[mockHUD expect] updateLayoutFrames];
    
    [mockHUD applyLayoutFrames];
    
    [mockHUD verify];
}

- (void)testChangingTitleSetsNeedsUpdate{
    self.hud.needsUpdate = NO;
    
    self.hud.titleText = @"test_text";
    
    GHAssertTrue(self.hud.needsUpdate, @"Needs update was not flagged on title change!");
}

- (void)testChangingMessageSetsNeedsUpdate{
    self.hud.needsUpdate = NO;
    
    self.hud.messageText = @"test_text";
    
    GHAssertTrue(self.hud.needsUpdate, @"Needs update was not flagged on message change!");
}

- (void)testUpdateTitleSetsNeedsUpdateAndResetsNeedsUpdate{
    self.hud.needsUpdate = NO;
    
    [self.hud updateTitle:@"new_title" animated:NO];
    
    GHAssertFalse(self.hud.needsUpdate, @"Updating title did not un-flag HUD for layout update!");
}

- (void)testUpdateMessageSetsNeedsUpdateAndResetsNeedsUpdate{
    self.hud.needsUpdate = NO;
    
    [self.hud updateMessage:@"new_message" animated:NO];
    
    GHAssertFalse(self.hud.needsUpdate, @"Updating message did not un-flag HUD for layout update!");
}

- (void)testUpdateTitleCallsUpdateLayout{
    id mockHUD = [OCMockObject partialMockForObject:self.hud];
    
    [[mockHUD expect] updateLayoutFrames];
    
    [mockHUD updateTitle:@"new_title" animated:NO];
    
    [mockHUD verify];
}

- (void)testUpdateMessageCallsUpdateLayout{
    id mockHUD = [OCMockObject partialMockForObject:self.hud];
    
    [[mockHUD expect] updateLayoutFrames];
    
    [mockHUD updateMessage:@"new_title" animated:NO];
    
    [mockHUD verify];
}

- (void)testUpdateNonAnimatedFiresCompletionBlock{
    id mockHUD = [OCMockObject partialMockForObject:self.hud];
    
    [[mockHUD expect] setProgress:0.f];
    
    [mockHUD updateAnimated:NO withCompletion:^(BOOL completed) {
        [mockHUD setProgress:0.f];
    }];
    
    [mockHUD verify];
}

- (void)testUpdateAnimatedFiresCompletionBlock{
    
    [self prepare];
    
    [self.hud updateAnimated:YES withCompletion:^(BOOL completed) {
        [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.f];
}

- (void)testActivityIndicatorNotNil{
    GHAssertNotNil(self.hud.activityIndicator, @"Activity indicator is nil!");
}

- (void)testProgressViewContainerIsNotNil{
    GHAssertNotNil(self.hud.progressViewContainer, @"Progress view container is nil!");
}

- (void)testSetProgressSetsProgress{
    CGFloat progressToSet = 0.3f;
    
    [self.hud setProgress:progressToSet];
    
    GHAssertTrue(self.hud.progress == progressToSet, @"Progress did not get set properly!");
}

- (void)testPrepareForReuseResetsTitleLabel{
    self.hud.titleLabel.text = @"text";
    
    [self.hud prepareForReuse];
    
    GHAssertNil(self.hud.titleLabel.text, @"Title label text did not get nil'd out!");
}

- (void)testPrepareForReuseResetsMessageLabel{
    self.hud.statusLabel.text = @"text";
    
    [self.hud prepareForReuse];
    
    GHAssertNil(self.hud.statusLabel.text, @"Message label text did not get nil'd out!");
}

- (void)testPrepareForReuseResetsImageViewImage{
    UIImage *image1 = [self.hud.delegate hud:self.hud imageForCompletionState:MMProgressHUDCompletionStateError];
    
    self.hud.imageView.image = image1;
    
    [self.hud prepareForReuse];
    
    GHAssertNil(self.hud.imageView.image, @"Image view's image did not get nil'd out!");
}

- (void)testPrepareForReuseResetsAnimationImages{
    UIImage *image1 = [self.hud.delegate hud:self.hud imageForCompletionState:MMProgressHUDCompletionStateError];
    UIImage *image2 = [self.hud.delegate hud:self.hud imageForCompletionState:MMProgressHUDCompletionStateSuccess];
    
    NSArray *animationImages = @[image1, image2];
    
    [self.hud.imageView setAnimationImages:animationImages];
    
    [self.hud prepareForReuse];
    
    GHAssertTrue(self.hud.imageView.animationImages.count == 0, @"Animation images did not get nil'd out!");
}

- (void)testPrepareForReuseResetsProgress{
    self.hud.progress = 0.5f;
    
    [self.hud prepareForReuse];
    
    GHAssertTrue(self.hud.progress == 0.f, @"Progress did not get reset!");
}

- (void)testPrepareForReuseResetsTransform{
    self.hud.layer.transform = CATransform3DMakeScale(2.0, 2.0, 2.0);
    
    [self.hud prepareForReuse];
    
    GHAssertTrue(CATransform3DIsIdentity(self.hud.layer.transform), @"Transform did not get reset in prepareForReuse!");
}

- (void)testPrepareForReuseResetsOpacity{
    self.hud.layer.opacity = 0.5f;
    
    [self.hud prepareForReuse];
    
    GHAssertTrue(self.hud.layer.opacity == 1.f, @"Opacity did not get reset in prepareForReuse!");
}

- (void)testPrepareForReuseResetsCompletionState{
    self.hud.completionState = MMProgressHUDCompletionStateError;
    
    [self.hud prepareForReuse];
    
    GHAssertTrue(self.hud.completionState == MMProgressHUDCompletionStateNone, @"Completion state did not get reset in prepareForReuse!");
}

- (void)testPrepareForReuseResetsVisibilityFlag{
    self.hud.visible = YES;
    
    GHAssertTrue(self.hud.isVisible, @"HUD did not get flagged as visible!");
    
    [self.hud prepareForReuse];
    
    GHAssertFalse(self.hud.isVisible, @"Progress hud is still flagged as visible after prepareForReuse!");
}

@end
