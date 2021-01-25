//
//  CameraVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

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
                
                cacheFind(in: currentImage)
            }
        }
    }
    
    func handleCachedText(request: VNRequest?, error: Error?, thisProcessIdentifier: UUID) {
        
        guard thisProcessIdentifier == currentCachingProcess else { return }
        
        guard let results = request?.results, results.count > 0 else {
            return
        }
        
        var contents = [EditableSingleHistoryContent]()
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    print("text: \(text.string)")
                    let origX = observation.boundingBox.origin.x
                    let origY = 1 - observation.boundingBox.minY
                    let origWidth = observation.boundingBox.width
                    let origHeight = observation.boundingBox.height
                    
                    let singleContent = EditableSingleHistoryContent()
                    singleContent.text = text.string
                    singleContent.x = origX
                    singleContent.y = origY
                    singleContent.width = origWidth
                    singleContent.height = origHeight
                    contents.append(singleContent)
                }
            }
            
        }
        finishedCaching = true
        cachedContents = contents
        if cachePressed {
            DispatchQueue.main.async {
                self.messageView.hideMessages()
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Cached"
            }
        }
    }
}
