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

        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        scrollZoomViewController.addChildViewController(highlightsViewController, in: scrollZoomViewController.drawingView)
    }
    
    func getHighlights(from sentences: [Sentence]) -> Set<Highlight> {
        var highlights = Set<Highlight>()
        for sentence in sentences {
            for (string, gradient) in self.searchViewModel.stringToGradients {
                let indices = sentence.string.lowercased().indicesOf(string: string.lowercased())
                for index in indices {
                    let word = sentence.getWord(word: string, at: index)
                    
                    let highlight = Highlight(
                        string: string,
                        frame: word.frame,
                        colors: gradient.colors,
                        alpha: gradient.alpha
                    )
                    highlights.insert(highlight)
                }
            }
        }
        return highlights
    }
    
    /// replaces highlights completely
    func updateHighlightColors() {
        var newHighlights = Set<Highlight>()
        let stringToGradients = searchViewModel.stringToGradients
        
        for index in highlightsViewModel.highlights.indices {
            let highlight = highlightsViewModel.highlights[index]
            let gradient = stringToGradients[highlight.string]
            var newHighlight = highlight
            
            if let gradient = gradient {
                newHighlight.colors = gradient.colors
                newHighlight.alpha = gradient.alpha
            }
            
            newHighlights.insert(newHighlight)
        }
        
        self.highlightsViewModel.highlights = newHighlights
    }
}
