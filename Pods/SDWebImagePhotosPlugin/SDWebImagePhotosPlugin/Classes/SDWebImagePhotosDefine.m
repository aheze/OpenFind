/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImagePhotosDefine.h"

NSString * _Nonnull const SDWebImagePhotosScheme = @"ph";
// PHImageManagerMaximumSize value is (-1.0, -1.0)
const CGSize SDWebImagePhotosPixelSize = {.width = -2.0, .height = -2.0};
const CGSize SDWebImagePhotosPointSize = {.width = -3.0, .height = -3.0};
const int64_t SDWebImagePhotosProgressExpectedSize = 100LL;

SDWebImageContextOption _Nonnull const SDWebImageContextPhotosFetchOptions = @"photosFetchOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosImageRequestOptions = @"photosImageRequestOptions";
SDWebImageContextOption _Nonnull const SDWebImageContextPhotosRequestImageData = @"photosRequestImageData";
