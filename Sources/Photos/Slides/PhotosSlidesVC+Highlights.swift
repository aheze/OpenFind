//
//  PhotosSlidesVC+Highlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosSlidesViewController {
    
    /// replaces highlights completely
    func updateHighlightColors(for model: HighlightsViewModel, with stringToGradients: [String: Gradient]) {
        let newHighlights = getUpdatedHighlightsColors(oldHighlights: model.highlights, newStringToGradients: stringToGradients)
        model.highlights = newHighlights
    }
    
    func getUpdatedHighlightsColors(oldHighlights: [Highlight], newStringToGradients: [String: Gradient]) -> [Highlight] {
        var newHighlights = [Highlight]()
        
        for index in oldHighlights.indices {
            let highlight = oldHighlights[index]
            let gradient = newStringToGradients[highlight.string]
            var newHighlight = highlight
            
            if let gradient = gradient {
                newHighlight.colors = gradient.colors
                newHighlight.alpha = gradient.alpha
            }
            
            newHighlights.append(newHighlight)
        }
        
        return newHighlights
    }
}
