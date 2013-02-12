//
//  CoverageFix.m
//  CategoriesExample
//
//  Created by Jasdeep Saini on 5/31/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "CoverageFix.h"


@implementation CoverageFix

FILE* fopen$UNIX2003(const char* filename, const char* mode) {
    return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void* ptr, size_t size, size_t nitems, FILE* stream) {
    return fwrite(ptr, size, nitems, stream);
}

@end