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
        if self.savePressed {
            self.saveImageToPhotos(cachePressed: cachePressed)
        }
    }
    func resetState() {
        self.savePressed = false
        UIView.animate(withDuration: Double(Constants.transitionDuration)) {
            self.saveToPhotos.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
        }
        self.saveLabel.fadeTransition(0.2)
        
        let saveText = NSLocalizedString("saveText", comment: "")
        self.saveLabel.text = saveText
        
        self.cachePressed = false
        self.cache.cacheIcon.animateCheck(percentage: 0)
        self.cache.cacheIcon.toggleRim(light: false)
        self.cacheLabel.fadeTransition(0.2)
        self.cacheLabel.text = NSLocalizedString("shouldCache", comment: "")
        
        self.messageView.hideMessages()
        self.startedCaching = false
        self.cachedComponents.removeAll()
        self.currentCachingProcess = nil
        self.finishedCaching = false
        self.currentCachingProcess = nil
        
        self.currentProgress = 0
        
        if let cacheTipView = self.cacheTipView {
            cacheTipView.dismiss()
        }
        self.cacheTipView = nil
        self.dismissedCacheTipAlready = false
        self.howManyTimesFastFoundSincePaused = 0
    }
    
}
