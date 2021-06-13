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
        
        DispatchQueue.main.async {
            var transcriptComponents = [Component]()
            
            if let results = request?.results, results.count > 0 {
                
                for result in results {
                    if let observation = result as? VNRecognizedTextObservation {
                        let convertedRect = self.getConvertedRect(
                            boundingBox: observation.boundingBox,
                            inImage: self.pixelBufferSize,
                            containedIn: self.cameraView.bounds.size
                        )
                                
                        for text in observation.topCandidates(1) {
                            
                            let transcriptComponent = Component()
                            transcriptComponent.text = text.string.lowercased()
                            transcriptComponent.x = convertedRect.origin.x
                            transcriptComponent.y = convertedRect.origin.y
                            transcriptComponent.width = convertedRect.width
                            transcriptComponent.height = convertedRect.height
                            transcriptComponents.append(transcriptComponent)
                            
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
            
            self.resetHighlights(updateMatchesLabel: false)
            
            self.currentTranscriptComponents = transcriptComponents
            self.drawAllTranscripts(show: self.showingTranscripts)
            self.finishedCache(with: transcriptComponents, rawContents: rawContents)
            
        }
    }
}
