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

#import "UCDBClient.h"
#import "UCDBKeyValueObject.h"

FOUNDATION_EXPORT double UCDBClientVersionNumber;
FOUNDATION_EXPORT const unsigned char UCDBClientVersionString[];

