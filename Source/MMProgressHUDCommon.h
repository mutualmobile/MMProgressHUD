//
//  MMCommonHeader.h
//  MMProgressHUDDemo
//
//  Created by Lars Anderson on 10/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#ifndef MM_PROGRESS_HUD_COMMON_H
#define MM_PROGRESS_HUD_COMMON_H
#ifdef DEBUG
#ifdef MM_HUD_DEBUG
#define MMHudLog(fmt, ...) NSLog((@"%@ [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)
#else
#define MMHudLog(...) /* */
#endif
#else
#define MMHudLog(...) /* */
#endif

#define MMHudWLog(fmt, ...) NSLog((@"%@ WARNING [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)

#ifdef __cplusplus
#define MMExtern extern "C"
#else
#define MMExtern extern
#endif

#endif// MM_PROGRESS_HUD_COMMON_H
