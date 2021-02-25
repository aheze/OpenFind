//
//  CameraVC+HandleCache.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension CameraViewController {
    func handleCachedText(request: VNRequest?, error: Error?, thisProcessIdentifier: UUID) {
        guard thisProcessIdentifier == currentCachingProcess else { return }
        
        guard let results = request?.results, results.count > 0 else {
            print("no results")
            finishedCache(with: [EditableSingleHistoryContent]())
            return
        }
        
        var contents = [EditableSingleHistoryContent]()
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
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
        
        finishedCache(with: contents)
    }
}
