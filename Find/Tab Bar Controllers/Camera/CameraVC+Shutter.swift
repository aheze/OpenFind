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
        cameraIcon.toggle(on: CameraState.isPaused)
        cameraChanged?(CameraState.isPaused, true)
        
        if CameraState.isPaused {
            pauseLivePreview()
            
            if TipViews.currentLocalStep == 2 {
                startLocalThirdStep()
            }
            let hasPausedBefore = UserDefaults.standard.bool(forKey: "hasPausedBefore")
            if !hasPausedBefore {
                UserDefaults.standard.set(true, forKey: "hasPausedBefore")
                showCacheTip()
            }
            cameraIcon.animateLoading(start: true)
        } else {
            saveToPhotosIfNeeded()
            resetState()
            startLivePreview()
            
            /// clear drawing view
            resetHighlights()
            resetTranscripts()
            
            cameraIcon.animateLoading(start: false)
            AppStoreReviewManager.requestReviewIfPossible()
        }
        
        removeFocusRects(CameraState.isPaused)
        adjustButtonLayout(CameraState.isPaused) /// rearrange buttons
        lockFlashlight(lock: CameraState.isPaused)
    }
}
