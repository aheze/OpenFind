/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
@import SDWebImage;
#endif

/**
 * The scheme when identifing the URL is Photos URL
 */
FOUNDATION_EXPORT NSString * _Nonnull const SDWebImagePhotosScheme;

/**
 * Specify to use the exact size of image instead of original pixel size.
 * Use this size if you want full image that PHImageManagerMaximumSize can not provide. This is the designed behavior for PhotoKit.
 * @note SDWebImagePhotosPixelSize > PHImageManagerMaximumSize(default) > SDWebImagePhotosPointSize
 */
FOUNDATION_EXPORT const CGSize SDWebImagePhotosPixelSize;

/**
 * Specify to use the exact size of image instead of original point size.
 * The scale is from the custom scale factor, or using the device scale factor if not provide.
 */
FOUNDATION_EXPORT const CGSize SDWebImagePhotosPointSize;

/**
 * Because Photos Framework progressBlock does not contains the file size, only the progress. See `PHAssetImageProgressHandler`.
 * This value is used to represent the `exceptedSize`, and the `receivedSize` is calculated by multiplying with the progress value.
 */
FOUNDATION_EXPORT const int64_t SDWebImagePhotosProgressExpectedSize; /* 100LL */

/**
 A PHFetchOptions instance used in the Photos Library fetch process. If you do not provide, we will use the default options to fetch the asset. (PHFetchOptions)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextPhotosFetchOptions;

/**
 A PHImageRequestOptions instance used in the Photos Library image request process. If you do not provide, we will use the default options to fetch the image (PHImageRequestOptions)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextPhotosImageRequestOptions;

/**
 A Bool value specify whether or not, to use `requestImageDataForAsset:options:resultHandler:` instead of `requestImageForAsset:targetSize:contentMode:options:resultHandler:` API to request Asset's Image.
 By default, we automatically use `requestImageDataForAsset` for Animated Asset (GIF images), use `requestImageForAsset` for other Asset. If you provide a custom value, always using that value instead.
 If you care about the raw image data, you can enable this context option to get the raw image data in completion block.
 @note When query the raw image data, the `targetSize` and `contentMode` are ignored. You can use image transformer or other ways from your propose. See Apple's documentation for more details information. (NSNumber *)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextPhotosRequestImageData;
