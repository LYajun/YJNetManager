#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LGLog.h"
#import "LGLogFormatter.h"
#import "LGLogManager.h"

FOUNDATION_EXPORT double LGLogVersionNumber;
FOUNDATION_EXPORT const unsigned char LGLogVersionString[];

