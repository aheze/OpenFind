//
//  PhotoSlidesVC+FindFromCache.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func findAfterCached() {
        if matchToColors.keys.count >= 1 {
            let resultPhoto = resultPhotos[currentIndex]
            if let editableModel = resultPhoto.findPhoto.editableModel, editableModel.isDeepSearched {
                resultPhoto.currentMatchToColors = nil
                resultPhoto.components.removeAll()
                findFromCache(resultPhoto: resultPhoto, index: currentIndex)
            }
        }
    }

    func findFromCache(resultPhoto: ResultPhoto, index: Int) {
        numberCurrentlyFindingFromCache += 1
        
        var totalMatchNumber = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let editableModel = resultPhoto.findPhoto.editableModel else {
                self.numberCurrentlyFindingFromCache -= 1
                return
            }
              
            var numberOfMatches = 0 /// how many individual matches
            
            var transcriptComponents = [Component]()
            var components = [Component]()
            
            /// Cycle through each block of text. Each cont may be a line long.
            for content in editableModel.contents {
                let transcript = Component()
                transcript.x = content.x
                transcript.y = content.y
                transcript.width = content.width
                transcript.height = content.height
                transcript.text = content.text
                transcriptComponents.append(transcript)
                
                let lowercaseContentText = content.text.lowercased()
                let individualCharacterWidth = CGFloat(content.width) / CGFloat(lowercaseContentText.count)
                
                for match in self.matchToColors.keys {
                    if lowercaseContentText.contains(match) {
                        let finalW = individualCharacterWidth * CGFloat(match.count)
                        let indices = lowercaseContentText.indicesOf(string: match)
                        
                        for index in indices {
                            totalMatchNumber += 1
                            numberOfMatches += 1
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let finalX = CGFloat(content.x) + addedWidth
                            let newComponent = Component()
                            
                            newComponent.x = finalX
                            newComponent.y = CGFloat(content.y) - CGFloat(content.height)
                            newComponent.width = finalW
                            newComponent.height = CGFloat(content.height)
                            newComponent.text = match
                            newComponent.transcriptComponent = transcript
                            components.append(newComponent)
                        }
                    }
                }
            }
            
            self.numberCurrentlyFindingFromCache -= 1
            if self.numberCurrentlyFindingFromCache == 0 {
                if index == self.currentIndex {
                    resultPhoto.transcripts = transcriptComponents
                    resultPhoto.components = components
                    
                    DispatchQueue.main.async {
                        self.setPromptToHowManyCacheResults(howMany: totalMatchNumber)
                        self.drawHighlightsAndTranscripts()
                    }
                }
            }
        }
    }
}
