//
//  CameraVC+Shutter.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func toggleShutter() {
        CameraState.isPaused.toggle()
        self.cameraIcon.toggle(on: CameraState.isPaused)
        self.cameraChanged?(CameraState.isPaused, true)
        
        if CameraState.isPaused {
            self.pauseLivePreview()
            
            if TipViews.currentLocalStep == 2 {
                self.startLocalThirdStep()
            }
            let hasPausedBefore = UserDefaults.standard.bool(forKey: "hasPausedBefore")
            if !hasPausedBefore {
                UserDefaults.standard.set(true, forKey: "hasPausedBefore")
                self.showCacheTip()
            }
        } else {
            self.saveToPhotosIfNeeded()
            self.resetState()
            self.startLivePreview()
            
            /// clear drawing view
            self.resetHighlights()
            self.resetTranscripts()
            
            AppStoreReviewManager.requestReviewIfPossible()
        }
        
        self.removeFocusRects(CameraState.isPaused)
        self.adjustButtonLayout(CameraState.isPaused)
        self.lockFlashlight(lock: CameraState.isPaused)
    }
}
