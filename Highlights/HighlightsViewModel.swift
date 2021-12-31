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
    
//    var state: State
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class HighlightsViewModel: ObservableObject {
    @Published var reusedHighlights = Set<Highlight>()
    @Published var addedHighlights = Set<Highlight>()
    @Published var lingeringHighlights = Set<Highlight>()
    
    func update(with newHighlights: Set<Highlight>) {

        /// highlights that were reused
        var reusedHighlights = Set<Highlight>()
        
        /// highlights that were added
        var addedHighlights = Set<Highlight>()
        
        /// old highlights that are under probation
        var lingeringHighlights = Set<Highlight>()
        
//        var oldHighlights = self.reusedHighlights + self.addedHighlights + self.lingeringHighlights
        var oldHighlights = self.reusedHighlights.union(self.addedHighlights).union(self.addedHighlights)

        
        for newHighlight in newHighlights {
            
            var (minimumDistance, nearestHighlight): (CGFloat, Highlight?) = (.infinity, nil)
            
            for oldHighlight in oldHighlights where oldHighlight.string == newHighlight.string {
                let distance = relativeDistance(oldHighlight.frame.center, newHighlight.frame.center)
                if distance < minimumDistance {
                    minimumDistance = distance
                    nearestHighlight = oldHighlight
                }
            }
            
            if
                let nearestHighlight = nearestHighlight,
                minimumDistance < HighlightsConstants.maximumHighlightTransitionProximitySquared
            {
                /// previous highlight existed, animate over
                var reusedHighlight = nearestHighlight
                reusedHighlight.frame = newHighlight.frame
                reusedHighlights.insert(reusedHighlight)
                oldHighlights.remove(nearestHighlight)
            } else {
                /// add the new highlight (fade in)
                addedHighlights.insert(newHighlight)
            }
            
        }
        
        
        for oldHighlight in oldHighlights {
            var lingeringHighlight = oldHighlight
            lingeringHighlight.cyclesWithoutNeighbor += 1
            
            if lingeringHighlight.cyclesWithoutNeighbor <= HighlightsConstants.maximumCyclesForLingeringHighlights {
                lingeringHighlights.insert(lingeringHighlight)
            }
        }
        
        print("reused: \(reusedHighlights.map { $0.frame })")
        print("added: \(addedHighlights.map { $0.frame })")
        print("lingering: \(lingeringHighlights.map { $0.frame })")
        withAnimation(.linear(duration: 1)) {
//            self.addedHighlights = newHighlights
            self.reusedHighlights = reusedHighlights
            self.addedHighlights = addedHighlights
            self.lingeringHighlights = lingeringHighlights
        }
    }
    
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
