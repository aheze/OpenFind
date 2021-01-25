//
//  CameraVC+FinishedCache.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func finishedCache(with contents: [EditableSingleHistoryContent]) {
        print("Finsihed, curr count: \(self.currentComponents.count)")
        finishedCaching = true
        cachedContents = contents
        if cachePressed {
            DispatchQueue.main.async {
                self.messageView.hideMessages()
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Cached"
            }
        }
        
        addCacheResults()
    }
    
    /// add cache results to fast found results
    func addCacheResults() {
        
        numberCurrentlyFindingFromCache += 1
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var numberOfMatches = 0 /// how many individual matches
            
            var components = [Component]()
            
            let convertedOriginalWidthOfBigImage = self.aspectRatioWidthOverHeight * self.deviceSize.height
            let offsetWidth = convertedOriginalWidthOfBigImage - self.deviceSize.width
            let offHalf = offsetWidth / 2
//            let newW = component.width * convertedOriginalWidthOfBigImage
//            let newH = component.height * self.deviceSize.height
//            let newX = component.x * convertedOriginalWidthOfBigImage - offHalf
//            let newY = (component.y * self.deviceSize.height) - newH
//            let individualCharacterWidth = newW / CGFloat(component.text.count)
            
            ///Cycle through each block of text. Each cont may be a line long.
            for content in self.cachedContents {
                
                let lowercaseContentText = content.text.lowercased()
                let individualCharacterWidth = CGFloat(content.width) / CGFloat(lowercaseContentText.count)
                
                for match in self.matchToColors.keys {
                    if lowercaseContentText.contains(match) {
                        let finalW = individualCharacterWidth * CGFloat(match.count)
                        let indices = lowercaseContentText.indicesOf(string: match)
                        
                        for index in indices {
                            numberOfMatches += 1
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let finalX = CGFloat(content.x) + addedWidth
                            let newComponent = Component()
                            
                            newComponent.width = finalW * convertedOriginalWidthOfBigImage
                            newComponent.height = CGFloat(content.height * self.deviceSize.height)
                            newComponent.x = finalX * convertedOriginalWidthOfBigImage - offHalf
                            newComponent.y = CGFloat(content.y * self.deviceSize.height) - newComponent.height
                            newComponent.text = match
                            
                            if self.shouldShowTextDetectIndicator {
                                self.drawFastHighlight(component: newComponent)
                            }
                            
                            newComponent.x -= 6
                            newComponent.y -= 3
                            newComponent.width += 12
                            newComponent.height += 6
                            
                            components.append(newComponent)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                for subView in self.drawingView.subviews {
                    subView.removeFromSuperview()
                }
            }
            
            self.numberCurrentlyFindingFromCache -= 1
            if self.numberCurrentlyFindingFromCache == 0 {
                
                self.highlightsFromCache = components
                self.currentComponents = components
                self.drawHighlights(highlights: components)
            }
        }
    }
}

extension CameraViewController {
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
