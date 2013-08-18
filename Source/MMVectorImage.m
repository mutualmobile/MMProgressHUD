//
//  MMVectorImage.m
//  MMProgressHUD
//
//  Created by Lars Anderson on 2/17/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMVectorImage.h"

@implementation MMVectorImage

+ (UIImage *)vectorImageShapeOfType:(MMVectorShapeType)shapeType size:(CGSize)size fillColor:(UIColor *)fillColor{
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGSize imageSize = size;
    if (size.width != size.height) {
        CGFloat dimension = MAX(size.width, size.height);
        imageSize = CGSizeMake(dimension, dimension);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    
    [self drawShapeOfType:shapeType size:imageSize fillColor:fillColor];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)drawShapeOfType:(MMVectorShapeType)shapeType size:(CGSize)size fillColor:(UIColor *)fillColor{
    CGSize vectorSize = CGSizeMake(512.f, 512.f);//vector strings based on 512x512 size
    NSString *pointsString = [self vectorPointStringForShapeType:shapeType];
    NSArray *pointsStringArray = [pointsString componentsSeparatedByString:@" "];
    UIBezierPath *vectorPath = [UIBezierPath bezierPath];
    for (NSString *point in pointsStringArray) {
        NSArray *individualPoint = [point componentsSeparatedByString:@","];
        CGFloat x = [individualPoint[0] floatValue]/vectorSize.width;
        CGFloat y = [individualPoint[1] floatValue]/vectorSize.height;
        CGPoint newPoint = CGPointMake(x*size.width, y*size.height);
        if ([vectorPath isEmpty]) {
            [vectorPath moveToPoint:newPoint];
        }
        else{
            [vectorPath addLineToPoint:newPoint];
        }
    }
    
    if ([vectorPath isEmpty] == NO) {
        [vectorPath closePath];
        
        [fillColor setFill];
        
        [vectorPath fill];
    }
}

+ (NSString *)checkMarkVectorString{
    return @"434.442,58.997 195.559,297.881 77.554,179.88 0,257.438 195.559,453.003 512,136.551";
}

+ (NSString *)xMarkVectorString{
    return @"512,120.859 391.141,0 255.997,135.146 120.855,0 0,120.859 135.132,256.006 0,391.146 120.855,512 255.997,376.872 391.141,512 512,391.146 376.862,256.006";
}

+ (NSString *)vectorPointStringForShapeType:(MMVectorShapeType)shapeType{
    switch (shapeType) {
        case MMVectorShapeTypeCheck:
            return [self checkMarkVectorString];
        case MMVectorShapeTypeX:
            return [self xMarkVectorString];
    }
}

@end
