#ifdef __OBJC__
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import <SDWebImagePhotosPlugin/NSURL+SDWebImagePhotosPlugin.h>
#import <SDWebImagePhotosPlugin/PHImageRequestOptions+SDWebImagePhotosPlugin.h>
#import <SDWebImagePhotosPlugin/SDWebImagePhotosDefine.h>
#import <SDWebImagePhotosPlugin/SDWebImagePhotosError.h>
#import <SDWebImagePhotosPlugin/SDImagePhotosLoader.h>

FOUNDATION_EXPORT double SDWebImagePhotosPluginVersionNumber;
FOUNDATION_EXPORT const unsigned char SDWebImagePhotosPluginVersionString[];

