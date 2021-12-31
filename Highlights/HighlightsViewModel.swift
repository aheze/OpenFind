//
//  HighlightsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct Highlight: Identifiable, Hashable {
    let id = UUID()
    var string = ""
    var frame = CGRect.zero
    var colors = [UIColor]()
    
    /// how many frames the highlight wasn't near any other new highlights
    var cyclesWithoutNeighbor = 0
    
    var state = State.added
    
    enum State {
        case reused
        case added
        case lingering
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class HighlightsViewModel: ObservableObject {
    @Published var highlights = Set<Highlight>()

    func update(with newHighlights: Set<Highlight>) {

        var nextHighlights = Set<Highlight>()
        
        /// lingering last
        var oldHighlights = Array(highlights)
        oldHighlights.sort { a, b in
            return b.state == .lingering
        }
        
        for newHighlight in newHighlights {
            
            var (minimumDistance, nearestHighlight, nearestHighlightIndex): (CGFloat, Highlight?, Int?) = (.infinity, nil, nil)
            
            for oldHighlightIndex in oldHighlights.indices {
                let oldHighlight = oldHighlights[oldHighlightIndex]
                guard oldHighlight.string == newHighlight.string else { continue }
                
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
                nextHighlights.insert(reusedHighlight)
                oldHighlights.remove(at: nearestHighlightIndex)
                
            } else {
                /// add the new highlight (fade in)
                var addedHighlight = newHighlight
                addedHighlight.state = .added
                nextHighlights.insert(addedHighlight)
            }
            
        }
        
        for oldHighlight in oldHighlights {
            var lingeringHighlight = oldHighlight
            lingeringHighlight.cyclesWithoutNeighbor += 1
            lingeringHighlight.state = .lingering
            
            if lingeringHighlight.cyclesWithoutNeighbor <= HighlightsConstants.maximumCyclesForLingeringHighlights {
                nextHighlights.insert(lingeringHighlight)
            }
        }
        
        withAnimation(.easeOut(duration: 0.6)) {
            self.highlights = nextHighlights
        }
    }
    
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
