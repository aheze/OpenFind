/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Photos/Photos.h>

/// PHImageRequestOptions category to provide targetSize and contentMode when fetch Photos image asset
@interface PHImageRequestOptions (SDWebImagePhotosPlugin)

/**
 The `targetSize` value for image asset request. Defaults to `PHImageManagerMaximumSize`.
 */
@property (nonatomic, assign) CGSize sd_targetSize;

/**
 The `contentMode` value for image asset request. Defaults to `PHImageContentModeDefault`.
 */
@property (nonatomic, assign) PHImageContentMode sd_contentMode;

@end
