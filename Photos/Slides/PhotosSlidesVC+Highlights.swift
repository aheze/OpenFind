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
        var newHighlights = Set<Highlight>()
        
        for index in model.highlights.indices {
            let highlight = model.highlights[index]
            let gradient = stringToGradients[highlight.string]
            var newHighlight = highlight
            
            if let gradient = gradient {
                newHighlight.colors = gradient.colors
                newHighlight.alpha = gradient.alpha
            }
            
            newHighlights.insert(newHighlight)
        }
        
        model.highlights = newHighlights
    }
}
