//
//  CameraVC+Resume.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func saveToPhotosIfNeeded() {
        if savePressed {
            saveImageToPhotos(cachePressed: cachePressed)
        }
    }

    func resetState() {
        savePressed = false
        UIView.animate(withDuration: Double(FindConstants.transitionDuration)) {
            self.saveToPhotos.photosIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)()
        }
        saveLabel.fadeTransition(0.2)
        
        let saveText = NSLocalizedString("saveText", comment: "")
        saveLabel.text = saveText
        
        cachePressed = false
        cache.cacheIcon.animateCheck(percentage: 0)
        cache.cacheIcon.toggleRim(light: false)
        cacheLabel.fadeTransition(0.2)
        cacheLabel.text = NSLocalizedString("shouldCache", comment: "")
        
        messageView.hideMessages()
        startedCaching = false
        cachedComponents.removeAll()
        currentCachingProcess = nil
        finishedCaching = false
        currentCachingProcess = nil
        
        currentProgress = 0
        
        if let cacheTipView = cacheTipView {
            cacheTipView.dismiss()
        }
        cacheTipView = nil
        dismissedCacheTipAlready = false
        howManyTimesFastFoundSincePaused = 0
    }
}
