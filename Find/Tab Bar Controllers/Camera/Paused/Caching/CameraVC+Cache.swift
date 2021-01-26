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
        if startedCaching {
            if finishedCaching {
                cache.cacheIcon.animateCheck(percentage: 1)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = "Cached"
            } else {
                cache.cacheIcon.animateCheck(percentage: currentProgress)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = "Caching..."
                messageView.unHideMessages()
            }
        } else {
            if let currentImage = currentPausedImage?.cgImage {
                cache.cacheIcon.animateCheck(percentage: 0)
                cache.cacheIcon.toggleRim(light: true)
                cacheLabel.fadeTransition(0.2)
                cacheLabel.text = "Caching..."
                messageView.showMessage("0", dismissible: false, duration: -1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.messageView.showMessage("25", dismissible: false, duration: -1)
                }
                
                cacheFind(in: currentImage)
            }
        }
    }
}
