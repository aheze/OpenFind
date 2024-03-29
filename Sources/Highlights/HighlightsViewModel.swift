//
//  HighlightsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

class HighlightsViewModel: ObservableObject {
    @Published var highlights = [Highlight]()
    
    @Published var overlays = [Overlay]()
    
    @Published var showOverlays = false
    
    /// If not up to date, fade out a bit.
    @Published var upToDate = true
    
    /// scale to the container. If false, just display them
    @Published var shouldScaleHighlights = true

    /// If replace, don't check if word is same, but make sure color is same
    func update(with newHighlights: [Highlight], replace: Bool) {
        var nextHighlights = [Highlight]()
        
        /// lingering last
        var oldHighlights = highlights
        oldHighlights.sort { _, b in
            if case .lingering = b.state {
                return true
            } else {
                return false
            }
        }
        
        for newHighlight in newHighlights {
            var (minimumDistance, nearestHighlight, nearestHighlightIndex): (CGFloat, Highlight?, Int?) = (.infinity, nil, nil)
            
            for oldHighlightIndex in oldHighlights.indices {
                let oldHighlight = oldHighlights[oldHighlightIndex]
                
                /// don't check if the word is the same if replacing
                guard (replace && oldHighlight.colors == newHighlight.colors) || (oldHighlight.string == newHighlight.string) else { continue }
                
                let distance = relativeDistance(oldHighlight.position.center, newHighlight.position.center)
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
                reusedHighlight.position = newHighlight.position
                reusedHighlight.state = .reused
                reusedHighlight.colors = newHighlight.colors
                reusedHighlight.alpha = newHighlight.alpha
                nextHighlights.append(reusedHighlight)
                oldHighlights.remove(at: nearestHighlightIndex)
            } else {
                /// add the new highlight (fade in)
                var addedHighlight = newHighlight
                addedHighlight.state = .added
                nextHighlights.append(addedHighlight)
            }
        }
        
        /// if don't replace, is camera
        if !replace {
            for oldHighlight in oldHighlights {
                var shouldInsert = false
                var lingeringHighlight = oldHighlight
                if case .lingering(let currentCyclesWithoutNeighbor) = lingeringHighlight.state {
                    let cyclesWithoutNeighbor = currentCyclesWithoutNeighbor + 1
                    lingeringHighlight.state = .lingering(cyclesWithoutNeighbor: cyclesWithoutNeighbor)
                    shouldInsert = cyclesWithoutNeighbor <= HighlightsConstants.maximumCyclesForLingeringHighlights
                    
                } else {
                    let cyclesWithoutNeighbor = 1
                    lingeringHighlight.state = .lingering(cyclesWithoutNeighbor: cyclesWithoutNeighbor)
                    shouldInsert = cyclesWithoutNeighbor <= HighlightsConstants.maximumCyclesForLingeringHighlights
                }
                
                if shouldInsert {
                    nextHighlights.append(lingeringHighlight)
                }
            }
        }
        
        withAnimation(.easeOut(duration: 0.6)) {
            self.highlights = nextHighlights
            self.upToDate = true
        }
    }
    
    /// Fade in/out the highlights.
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
