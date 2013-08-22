//
//  MMProgressHUDDefines.h
//  MMProgressHUDDemo
//
//  Created by Jonas Gessner on 22.08.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#ifdef DEBUG
#ifdef MM_HUD_DEBUG
#define MMHudLog(fmt, ...) NSLog((@"%@ [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)
#else
#define MMHudLog(...)
#endif
#else
#define MMHudLog(...)
#endif

#define MMHudWLog(fmt, ...) NSLog((@"%@ WARNING [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)

#ifdef __cplusplus
#define MMExtern extern "C"
#else
#define MMExtern extern
#endif