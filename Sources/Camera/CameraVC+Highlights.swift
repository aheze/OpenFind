//
//  CameraVC+Highlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func setupHighlights() {
        /// for highlights, make appear after frames are set

        let highlightsViewController = HighlightsViewController(
            highlightsViewModel: highlightsViewModel,
            realmModel: realmModel
        )
        
        scrollZoomViewController.addChildViewController(highlightsViewController, in: scrollZoomViewController.drawingView)
    }
  
    /// replaces highlights completely
    func updateHighlightColors() {
        var newHighlights = [Highlight]()
        let stringToGradients = searchViewModel.stringToGradients
        
        for index in highlightsViewModel.highlights.indices {
            let highlight = highlightsViewModel.highlights[index]
            let gradient = stringToGradients[highlight.string]
            var newHighlight = highlight
            
            if let gradient = gradient {
                newHighlight.colors = gradient.colors
                newHighlight.alpha = gradient.alpha
            }
            
            newHighlights.append(newHighlight)
        }
        
        self.highlightsViewModel.highlights = newHighlights
    }
    
    /// call this whenever update `highlightsViewModel.highlights`, except when just the colors changed
    func highlightsAdded() {
        if searchViewModel.isEmpty {
            model.actualResultsCount = .noTextEntered
        } else {
            model.actualResultsCount = .number(highlightsViewModel.highlights.count)
        }
    }
}
