/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "PHAsset+SDWebImagePhotosPlugin.h"
#import "NSURL+SDWebImagePhotosPlugin.h"

@implementation PHAsset (SDWebImagePhotosPlugin)

- (NSURL *)sd_URLRepresentation {
    return [NSURL sd_URLWithAsset:self];
}

@end
