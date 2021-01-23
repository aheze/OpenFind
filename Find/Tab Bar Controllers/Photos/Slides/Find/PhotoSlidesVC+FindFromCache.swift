//
//  PhotoSlidesVC+FindFromCache.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func findFromCache(resultPhoto: ResultPhoto, index: Int) {
        
        numberCurrentlyFindingFromCache += 1
        
        var totalMatchNumber = 0
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let editableModel = resultPhoto.findPhoto.editableModel else {
                self.numberCurrentlyFindingFromCache -= 1
                return
            }
              
            var numberOfMatches = 0 /// how many individual matches
            
            var components = [Component]()
            
            ///Cycle through each block of text. Each cont may be a line long.
            for content in editableModel.contents {
                
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
                            newComponent.y = CGFloat(content.y) - (CGFloat(content.height))
                            newComponent.width = finalW
                            newComponent.height = CGFloat(content.height)
                            newComponent.text = match
                            components.append(newComponent)
                        }
                    }
                }
            }
            
            
            
            self.numberCurrentlyFindingFromCache -= 1
            if self.numberCurrentlyFindingFromCache == 0 {
                
                if index == self.currentIndex {
                    resultPhoto.components = components
                    
                    DispatchQueue.main.async {
                        self.setPromptToHowManyCacheResults(howMany: totalMatchNumber)
                        self.drawHighlights(components: components)
                    }
                }
            }
        }
        
    }
}
