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
//        var contents = [EditableSingleHistoryContent]()
        
        DispatchQueue.main.async {
            var transcriptComponents = [Component]()
            var components = [Component]()
            
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
                            
                            let component = Component()
                            component.text = text.string.lowercased()
                            component.x = convertedRect.origin.x
                            component.y = convertedRect.origin.y
                            component.width = convertedRect.width
                            component.height = convertedRect.height
                            component.transcriptComponent = transcriptComponent
                            components.append(transcriptComponent)
                            
                            
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
                
                self.currentTranscriptComponents = transcriptComponents
                if CameraState.isPaused {
                    if self.showingTranscripts {
                        self.drawAllTranscripts()
                    }
                }
            }
            
            self.finishedCache(with: components, rawContents: rawContents)
            
        }
    }
}
