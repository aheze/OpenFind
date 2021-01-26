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
        self.saveLabel.text = "Save"
        
        self.cachePressed = false
        self.cache.cacheIcon.animateCheck(percentage: 0)
        self.cache.cacheIcon.toggleRim(light: false)
        self.cacheLabel.fadeTransition(0.2)
        self.cacheLabel.text = "Cache"
        
        self.messageView.hideMessages()
        self.startedCaching = false
        self.cachedContents.removeAll()
        self.currentCachingProcess = nil
        self.finishedCaching = false
        self.currentCachingProcess = nil
    }
    
}
