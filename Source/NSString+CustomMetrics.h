//
//  NSString+CustomMetrics.h
//  MMProgressHUDDemo
//
//  Created by Yannick Heinrich on 13/02/2014.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CustomMetrics)


- (CGSize) boundingRectWithSize:(CGSize) size andFont:(UIFont*) font;
@end
