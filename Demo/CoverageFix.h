//
//  CoverageFix.h
//  CategoriesExample
//
//  Created by Jasdeep Saini on 5/31/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This fixes a problem related to an Apple implementation of a core unix api.
 */
@interface CoverageFix : NSObject


FILE* fopen$UNIX2003(const char* filename, const char* mode);

size_t fwrite$UNIX2003(const void* ptr, size_t size, size_t nitems, FILE* stream);

@end