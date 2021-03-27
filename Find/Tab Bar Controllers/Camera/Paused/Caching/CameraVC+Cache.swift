//
//  CameraVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func beginCachingPhoto() {
        if let cacheTipView = self.cacheTipView {
            cacheTipView.dismiss()
        }
        if startedCaching {
            if finishedCaching {
                cache.cacheIcon.animateCheck(percentage: 1)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = NSLocalizedString("shouldNotCache", comment: "")
                addCacheResults()
                
                self.cache.accessibilityLabel = "Cached"
                self.cache.accessibilityHint = "Tap to uncache the current paused image"
            } else {
                cache.cacheIcon.animateCheck(percentage: currentProgress)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = NSLocalizedString("caching...", comment: "")
                messageView.unHideMessages()
                
                cache.accessibilityLabel = "Caching"
                cache.accessibilityHint = ""
                UIAccessibility.post(notification: .layoutChanged, argument: self.cache)
            }
        } else {
            if let currentImage = currentPausedImage?.cgImage {
                cache.cacheIcon.animateCheck(percentage: 0)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = NSLocalizedString("caching...", comment: "")
                messageView.showMessage("0", dismissible: false, duration: -1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if self.cachePressed {
                        if 0.25 > self.currentProgress {
                            self.messageView.showMessage("25", dismissible: false, duration: -1)
                            self.cache.cacheIcon.animateCheck(percentage: 0.25)
                            
                            UIAccessibility.post(notification: .announcement, argument: "25%")
                            
                        }
                    }
                }
                
                cacheFind(in: currentImage)
            }
        }
    }
}
