//
//  HighlightsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

class HighlightsViewModel: ObservableObject {
    @Published var highlights = Set<Highlight>()
    @Published var upToDate = true

    /// If replace, don't check if word is same, but make sure color is same
    func update(with newHighlights: Set<Highlight>, replace: Bool) {
        var nextHighlights = Set<Highlight>()
        
        /// lingering last
        var oldHighlights = Array(highlights)
        oldHighlights.sort { _, b in
            b.state == .lingering
        }
        
        for newHighlight in newHighlights {
            var (minimumDistance, nearestHighlight, nearestHighlightIndex): (CGFloat, Highlight?, Int?) = (.infinity, nil, nil)
            
            for oldHighlightIndex in oldHighlights.indices {
                let oldHighlight = oldHighlights[oldHighlightIndex]
                
                /// don't check if the word is the same if replacing
                guard (replace && oldHighlight.colors == newHighlight.colors) || (oldHighlight.string == newHighlight.string) else { continue }
                
                let distance = relativeDistance(oldHighlight.frame.center, newHighlight.frame.center)
                if distance < minimumDistance {
                    minimumDistance = distance
                    nearestHighlight = oldHighlight
                    nearestHighlightIndex = oldHighlightIndex
                }
            }
            
            if
                let nearestHighlight = nearestHighlight,
                let nearestHighlightIndex = nearestHighlightIndex,
                minimumDistance < HighlightsConstants.maximumHighlightTransitionProximitySquared
            {
                /// previous highlight existed, animate over
                var reusedHighlight = nearestHighlight
                reusedHighlight.cyclesWithoutNeighbor = 0
                reusedHighlight.frame = newHighlight.frame
                reusedHighlight.state = .reused
                reusedHighlight.colors = newHighlight.colors
                reusedHighlight.alpha = newHighlight.alpha
                nextHighlights.insert(reusedHighlight)
                oldHighlights.remove(at: nearestHighlightIndex)
            } else {
                /// add the new highlight (fade in)
                var addedHighlight = newHighlight
                addedHighlight.state = .added
                nextHighlights.insert(addedHighlight)
            }
        }
        
        
        if !replace {
            for oldHighlight in oldHighlights {
                var lingeringHighlight = oldHighlight
                lingeringHighlight.cyclesWithoutNeighbor += 1
                lingeringHighlight.state = .lingering
                
                if lingeringHighlight.cyclesWithoutNeighbor <= HighlightsConstants.maximumCyclesForLingeringHighlights {
                    nextHighlights.insert(lingeringHighlight)
                }
            }
        }
        
        withAnimation(.easeOut(duration: 0.6)) {
            self.highlights = nextHighlights
            self.upToDate = true
        }
    }
    
    func setUpToDate(_ upToDate: Bool) {
        withAnimation(.linear(duration: 0.3)) {
            self.upToDate = upToDate
        }
    }
    
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
