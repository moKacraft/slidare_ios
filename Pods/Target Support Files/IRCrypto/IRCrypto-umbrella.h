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

#import "IRCryptoHeader.h"
#import "IRCrypto.h"
#import "IRPublicConstants.h"

FOUNDATION_EXPORT double IRCryptoVersionNumber;
FOUNDATION_EXPORT const unsigned char IRCryptoVersionString[];

