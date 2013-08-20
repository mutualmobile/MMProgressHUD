//
//  MMVectorImage.h
//  MMProgressHUD
//
//  Created by Lars Anderson on 2/17/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMVectorShapeType) {
    MMVectorShapeTypeCheck = 0,
    MMVectorShapeTypeX
};

@interface MMVectorImage : NSObject

+ (UIImage *)vectorImageShapeOfType:(MMVectorShapeType)shapeType
                               size:(CGSize)size
                          fillColor:(UIColor *)fillColor;

@end
