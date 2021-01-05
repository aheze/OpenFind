/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "PHImageRequestOptions+SDWebImagePhotosPlugin.h"
#import "SDWebImagePhotosDefine.h"
#import <objc/runtime.h>

@implementation PHImageRequestOptions (SDWebImagePhotosPlugin)

- (CGSize)sd_targetSize {
    NSValue *value = objc_getAssociatedObject(self, @selector(sd_targetSize));
    if (!value) {
        return PHImageManagerMaximumSize;
    }
#if SD_MAC
    CGSize targetSize = value.sizeValue;
#else
    CGSize targetSize = value.CGSizeValue;
#endif
    return targetSize;
}

- (void)setSd_targetSize:(CGSize)sd_targetSize {
    objc_setAssociatedObject(self, @selector(sd_targetSize), @(sd_targetSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHImageContentMode)sd_contentMode {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sd_contentMode));
    if (value != nil) {
        return PHImageContentModeDefault;
    }
    return value.integerValue;
}

- (void)setSd_contentMode:(PHImageContentMode)sd_contentMode {
    objc_setAssociatedObject(self, @selector(sd_contentMode), @(sd_contentMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
