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
        
        var rawContents = [EditableSingleHistoryContent]() /// vision coordinates
        var contents = [EditableSingleHistoryContent]()
        
        DispatchQueue.main.async {
            if let results = request?.results, results.count > 0 {
                for result in results {
                    if let observation = result as? VNRecognizedTextObservation {
                        let convertedRect = self.getConvertedRect(
                            boundingBox: observation.boundingBox,
                            inImage: self.pixelBufferSize,
                            containedIn: self.cameraView.bounds.size
                        )
                        
                        for text in observation.topCandidates(1) {
                            let singleContent = EditableSingleHistoryContent()
                            singleContent.text = text.string
                            singleContent.x = convertedRect.origin.x
                            singleContent.y = convertedRect.origin.y
                            singleContent.width = convertedRect.width
                            singleContent.height = convertedRect.height
                            contents.append(singleContent)
                            
                            let origX = observation.boundingBox.origin.x
                            let origY = 1 - observation.boundingBox.minY
                            let origWidth = observation.boundingBox.width
                            let origHeight = observation.boundingBox.height
                            
                            let rawContent = EditableSingleHistoryContent()
                            rawContent.text = text.string
                            rawContent.x = origX
                            rawContent.y = origY
                            rawContent.width = origWidth
                            rawContent.height = origHeight
                            rawContents.append(rawContent)
                        }
                    }
                }
            }
            
            self.finishedCache(with: contents, rawContents: rawContents)
            
        }
    }
}
