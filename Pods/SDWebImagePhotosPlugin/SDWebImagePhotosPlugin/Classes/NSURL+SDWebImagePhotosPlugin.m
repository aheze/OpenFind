/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSURL+SDWebImagePhotosPlugin.h"
#import "SDWebImagePhotosDefine.h"
#import <Photos/Photos.h>
#import <objc/runtime.h>

@implementation NSURL (SDWebImagePhotosPlugin)

- (BOOL)sd_isPhotosURL {
    return [self.scheme isEqualToString:SDWebImagePhotosScheme];
}

- (NSString *)sd_assetLocalIdentifier {
    if (!self.sd_isPhotosURL) {
        return nil;
    }
    PHAsset *asset = self.sd_asset;
    if (asset) {
        return asset.localIdentifier;
    }
    NSString *urlString = self.absoluteString;
    NSString *prefix = [NSString stringWithFormat:@"%@://", SDWebImagePhotosScheme];
    if (urlString.length <= prefix.length) {
        return nil;
    }
    return [urlString stringByReplacingOccurrencesOfString:prefix withString:@""];
}

- (PHAsset *)sd_asset {
    return objc_getAssociatedObject(self, @selector(sd_asset));
}

- (void)setSd_asset:(PHAsset * _Nullable)sd_asset {
    objc_setAssociatedObject(self, @selector(sd_asset), sd_asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)sd_URLWithAssetLocalIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    // ph://F2A9F582-BA45-4308-924E-6D146B784A09/L0/001
    NSString *prefix = [NSString stringWithFormat:@"%@://", SDWebImagePhotosScheme];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", prefix, identifier]];
}

+ (instancetype)sd_URLWithAsset:(PHAsset *)asset {
    if (![asset isKindOfClass:[PHAsset class]]) {
        return nil;
    }
    NSString *localIdentifier = asset.localIdentifier;
    if (!localIdentifier) {
        return nil;
    }
    
    NSURL *url = [self sd_URLWithAssetLocalIdentifier:localIdentifier];
    url.sd_asset = asset;
    
    return url;
}

@end
