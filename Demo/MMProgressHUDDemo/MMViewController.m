//
//  MMViewController.m
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 5/4/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"

typedef NS_ENUM(NSInteger, MMProgressHUDDemoSections){
    MMProgressHUDDemoSectionFeatures = 0,
    MMProgressHUDDemoSectionAnimations,
    MMProgressHUDDemoSectionOverlays,
    MMProgressHUDDemoNumberOfSections
};

typedef NS_ENUM(NSInteger, MMProgressHUDDemoAnimationType){
    MMProgressHUDDemoAnimationTypeExpand = 0,
    MMProgressHUDDemoAnimationTypeShrink,
    MMProgressHUDDemoAnimationTypeSwingRight,
    MMProgressHUDDemoAnimationTypeSwingLeft,
    MMProgressHUDDemoAnimationTypeBalloon,
    MMProgressHUDDemoAnimationTypeDrop,
    MMProgressHUDDemoAnimationTypeFade,
    MMProgressHUDDemoNumberOfAnimationTypes//I know this goes directly against coding guidelines, but makes creating static tableviews with enums easier
};

typedef NS_ENUM(NSInteger, MMProgressHUDDemoOverlayType){
    MMProgressHUDDemoOverlayTypeGradient = 0,
    MMProgressHUDDemoOverlayTypeLinear,
//    MMProgressHUDDemoOverlayTypeBlur,
//    MMProgressHUDDemoOverlayTypeCoreImage,
    MMProgressHUDDemoNumberOfOverlayTypes
};

typedef NS_ENUM(NSInteger, MMProgressHUDDemoFeatureType){
    MMProgressHUDDemoTypeStylePlain = 0,
    MMProgressHUDDemoTypeStyleBordered,
    MMProgressHUDDemoTypeStaticImage,
    MMProgressHUDDemoTypeAnimatedImage,
    MMProgressHUDDemoTypeAutosizing,
    MMProgressHUDDemoTypeConfirmation,
    MMProgressHUDDemoTypeRadialProgress,
    MMProgressHUDDemoTypeOverlayColor,
    MMProgressHUDDemoNumberOfFeatureTypes
};

@implementation MMViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *images = @[[UIImage imageNamed:@"1.png"],
                       [UIImage imageNamed:@"2.png"],
                       [UIImage imageNamed:@"3.png"],
                       [UIImage imageNamed:@"4.png"],
                       [UIImage imageNamed:@"5.png"],
                       [UIImage imageNamed:@"6.png"]];
    UIImage *staticImage = [UIImage imageNamed:@"1.png"];
    BOOL autodismiss = YES;
    
    switch (indexPath.section) {
        case MMProgressHUDDemoSectionFeatures:
            switch (indexPath.row) {
                case MMProgressHUDDemoTypeAnimatedImage:
                    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeLinear];
                    [MMProgressHUD showWithTitle:@"Title" status:@"Custom Animated Image" images:images];
                    break;
                case MMProgressHUDDemoTypeAutosizing:
                    [MMProgressHUD showWithTitle:@"Moderately Long Title That Should Wrap"
                                          status:@"Bacon ipsum dolor sit amet cow tongue drumstick, prosciutto shank frankfurter leberkas corned beef capicola chicken. Sirloin jerky brisket salami pork."];
                    break;
                case MMProgressHUDDemoTypeConfirmation:
                    autodismiss = NO;
                    [MMProgressHUD showWithTitle:@"Long Task"
                                          status:@"Reticulating Splines..."
                             confirmationMessage:@"Cancel Download?"
                                     cancelBlock:^{
                                         NSLog(@"Task was cancelled!"); 
                                     }];
                    break;
                case MMProgressHUDDemoTypeStaticImage:
                    [MMProgressHUD showWithTitle:@"Image"
                                          status:@"Sweet Custom Image Action"
                                           image:staticImage];
                    break;
                case MMProgressHUDDemoTypeStyleBordered:
                    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStyleBordered];
                    [MMProgressHUD showWithTitle:@"Bordered" status:@"Bordered Style"];
                    break;
                case MMProgressHUDDemoTypeStylePlain:
                    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
                    [MMProgressHUD showWithTitle:@"Plain" status:@"No Border"];
                    break;
                case MMProgressHUDDemoTypeRadialProgress:
                    [MMProgressHUD showProgressWithStyle:MMProgressHUDProgressStyleRadial title:@"Radial Progress" status:nil];
                    [[MMProgressHUD sharedHUD] setProgressCompletion:^{
                       [MMProgressHUD dismissWithSuccess:@"Done!"]; 
                    }];
                    [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                        NSLog(@"I've been dismissed!"); 
                    }];
                    
                    autodismiss = NO;
                    
                    double delayInSeconds = 1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [MMProgressHUD updateProgress:0.33f];
                        
                        double delayInSeconds = 0.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [MMProgressHUD updateProgress:0.55f];
                            
                            double delayInSeconds = 0.8;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [MMProgressHUD updateProgress:0.80f];
                                
                                double delayInSeconds = 1.5;
                                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                    [MMProgressHUD updateProgress:1.f];
                                    
                                });
                            });
                        });
                    });
                    break;
                case MMProgressHUDDemoTypeOverlayColor:{
                    
                    //random color
                    CGFloat red =  arc4random_uniform(256)/255.f;
                    CGFloat blue = arc4random_uniform(256)/255.f;
                    CGFloat green = arc4random_uniform(256)/255.f;
                    
                    CGColorRef color = CGColorRetain([UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor);
                    
                    [[[MMProgressHUD sharedHUD] overlayView] setOverlayColor:color];
                    
                    CGColorRelease(color);
                    
                    [MMProgressHUD showWithTitle:@"Overlay" status:@"Random Color"];
                }
                    break;
            }
            break;
        case MMProgressHUDDemoSectionAnimations:
            switch (indexPath.row) {
                case MMProgressHUDDemoAnimationTypeBalloon:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleBalloon];
                    [MMProgressHUD showWithTitle:@"Animation" status:@"Balloon"];
                    break;
                case MMProgressHUDDemoAnimationTypeExpand:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
                    [MMProgressHUD showWithTitle:@"Animation" status:@"Expand"];
                    break;
                case MMProgressHUDDemoAnimationTypeShrink:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
                    [MMProgressHUD showWithTitle:@"Animation" status:@"Shrink"];
                    break;
                case MMProgressHUDDemoAnimationTypeSwingLeft:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleSwingLeft];
                    [MMProgressHUD showWithTitle:@"Swing" status:@"Left"];
                    break;
                case MMProgressHUDDemoAnimationTypeSwingRight:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleSwingRight];
                    [MMProgressHUD showWithTitle:@"Swing" status:@"Right"];
                    break;
                case MMProgressHUDDemoAnimationTypeDrop:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleDrop];
                    [MMProgressHUD showWithTitle:@"Animation" status:@"Drop"];
                    break;
                case MMProgressHUDDemoAnimationTypeFade:
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
                    [MMProgressHUD showWithTitle:@"Animation" status:@"Fade"];
                default:
                    break;
            }
            break;
        case MMProgressHUDDemoSectionOverlays:
            switch (indexPath.row) {
                case MMProgressHUDDemoOverlayTypeGradient:
                    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
                    
                    [MMProgressHUD showWithTitle:@"Overlay" status:@"Radial Gradient"];
                    break;
                case MMProgressHUDDemoOverlayTypeLinear:
                    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeLinear];
                    
                    [MMProgressHUD showWithTitle:@"Overlay" status:@"Linear"];
                    break;
//                case MMProgressHUDDemoOverlayTypeBlur:
//                    break;
                default:
                    break;
            }
            break;
    }
    
    if (autodismiss == YES) {
        double delayInSeconds = 2.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MMProgressHUD dismissWithSuccess:@"Success!"];
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return MMProgressHUDDemoNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case MMProgressHUDDemoSectionFeatures:
            return MMProgressHUDDemoNumberOfFeatureTypes;
        case MMProgressHUDDemoSectionAnimations:
            return MMProgressHUDDemoNumberOfAnimationTypes;
        case MMProgressHUDDemoSectionOverlays:
            return MMProgressHUDDemoNumberOfOverlayTypes;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case MMProgressHUDDemoSectionFeatures:
            return @"Features";
        case MMProgressHUDDemoSectionAnimations:
            return @"Presentation Styles";
        case MMProgressHUDDemoSectionOverlays:
            return @"Overlays";
        default:
            return nil;
    }
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = nil;
    
    switch (indexPath.section) {
        case MMProgressHUDDemoSectionFeatures:
            switch (indexPath.row) {
                case MMProgressHUDDemoTypeAnimatedImage:
                    title = @"Animated Images";
                    break;
                case MMProgressHUDDemoTypeAutosizing:
                    title = @"Animated Autosizing";
                    break;
                case MMProgressHUDDemoTypeConfirmation:
                    title = @"Confirmed User Cancellation";
                    break;
                case MMProgressHUDDemoTypeStaticImage:
                    title = @"Custom Static Images";
                    break;
                case MMProgressHUDDemoTypeStyleBordered:
                    title = @"Bordered Styling";
                    break;
                case MMProgressHUDDemoTypeStylePlain:
                    title = @"Plain Styling";
                    break;
                case MMProgressHUDDemoTypeRadialProgress:
                    title = @"Determinate Progress (Radial)";
                    break;
                case MMProgressHUDDemoTypeOverlayColor:
                    title = @"Custom Overlay Color (Random)";
            }
            break;
        case MMProgressHUDDemoSectionAnimations:
            switch (indexPath.row) {
                case MMProgressHUDDemoAnimationTypeBalloon:
                    title = @"Balloon";
                    break;
                case MMProgressHUDDemoAnimationTypeExpand:
                    title = @"Expand";
                    break;
                case MMProgressHUDDemoAnimationTypeShrink:
                    title = @"Shrink";
                    break;
                case MMProgressHUDDemoAnimationTypeSwingLeft:
                    title = @"Swing Left";
                    break;
                case MMProgressHUDDemoAnimationTypeSwingRight:
                    title = @"Swing Right";
                    break;
                case MMProgressHUDDemoAnimationTypeDrop:
                    title = @"Drop";
                    break;
                case MMProgressHUDDemoAnimationTypeFade:
                    title = @"Fade";
                    break;
                default:
                    break;
            }
            break;
        case MMProgressHUDDemoSectionOverlays:
            switch (indexPath.row) {
                case MMProgressHUDDemoOverlayTypeGradient:
                    title = @"Gradient";
                    break;
                case MMProgressHUDDemoOverlayTypeLinear:
                    title = @"Linear";
                    break;
                default:
                    break;
            }
    }
    
    cell.textLabel.text = title;
}

@end
