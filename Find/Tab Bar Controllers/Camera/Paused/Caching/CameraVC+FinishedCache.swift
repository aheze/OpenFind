//
//  CameraVC+FinishedCache.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func finishedCache(with components: [Component], rawContents: [EditableSingleHistoryContent]) {
        finishedCaching = true
        cachedComponents = components
        rawCachedContents = rawContents
        
        if cachePressed {
            DispatchQueue.main.async {
                self.messageView.updateMessage("100")
                self.messageView.hideMessages()
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = NSLocalizedString("shouldNotCache", comment: "")
                self.cache.cacheIcon.animateCheck(percentage: CGFloat(1))
                
                self.cache.accessibilityLabel = "Cached"
                self.cache.accessibilityHint = "Tap to uncache the current paused image"
                
                UIAccessibility.post(notification: .announcement, argument: "Caching complete")
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
           
            ///Cycle through each block of text. Each cont may be a line long.
            for cachedComponent in self.cachedComponents {
                
                let lowercaseContentText = cachedComponent.text
                let individualCharacterWidth = CGFloat(cachedComponent.width) / CGFloat(lowercaseContentText.count)
                
                for match in self.matchToColors.keys {
                    if lowercaseContentText.contains(match) {

                        let indices = lowercaseContentText.indicesOf(string: match)
                        
                        for index in indices {
                            numberOfMatches += 1
                            
                            let x = cachedComponent.x + (individualCharacterWidth * CGFloat(index))
                            let y = cachedComponent.y
                            let width = (individualCharacterWidth * CGFloat(match.count))
                            let height = cachedComponent.height
                            
                            let component = Component()
                            component.x = x - 6
                            component.y = y - 3
                            component.width = width + 12
                            component.height = height + 12
                            component.text = match.lowercased()
                            component.transcriptComponent = cachedComponent.transcriptComponent
                            
                            components.append(component)
                        }
                    }
                }
            }
            
            self.resetHighlights(updateMatchesLabel: false)
            
            self.numberCurrentlyFindingFromCache -= 1
            if self.numberCurrentlyFindingFromCache == 0 {
                self.highlightsFromCache = components
                self.currentComponents = components
                self.drawHighlights(highlights: components, shouldScale: true)
                
                self.updateMatchesNumber(to: components.count, tapHaptic: true)
                
                if components.count >= 1 {
                    AppStoreReviewManager.increaseReviewActionCount()
                }
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
