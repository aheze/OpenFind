/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

@class PHAsset;
/// NSURL category for Photos URL support
@interface NSURL (SDWebImagePhotosPlugin)

/**
 The localIdentifier value for Photos URL, or nil for other URL.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sd_assetLocalIdentifier;

/**
 The `PHAsset` value for Photos URL, or nil for other URL, or the `PHAsset` is not availble.
 */
@property (nonatomic, strong, readonly, nullable) PHAsset *sd_asset;

/**
 Check whether the current URL represents Photos URL.
 */
@property (nonatomic, assign, readonly) BOOL sd_isPhotosURL;

/**
 Create a Photos URL with `PHAsset` 's local identifier

 @param identifier `PHAsset` 's local identifier
 @return A Photos URL
 */
+ (nullable instancetype)sd_URLWithAssetLocalIdentifier:(nonnull NSString *)identifier;

/**
 Create a Photos URL with `PHAsset`

 @param asset `PHAsset` object
 @return A Photos URL
 */
+ (nullable instancetype)sd_URLWithAsset:(nonnull PHAsset *)asset;

@end
