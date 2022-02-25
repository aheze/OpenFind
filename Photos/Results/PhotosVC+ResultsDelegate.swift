//
//  PhotosVC+ResultsDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    func willDisplayResultsCell(cell: PhotosResultsCell, index: Int) {
        guard let resultsState = model.resultsState else { return }
        let findPhoto = resultsState.findPhotos[index]
        
        let highlightsViewModel = HighlightsViewModel()
            
        var cellHighlights = Set<Highlight>()
        for line in findPhoto.descriptionLines {
            guard
                let lineHighlights = line.lineHighlights,
                let textView = cell.descriptionTextView
            else { continue }
//            var cellHighlight = highlight
            
            for lineHighlight in lineHighlights {
                guard
                    let start = textView.position(from: textView.beginningOfDocument, offset: lineHighlight.rangeInSentence.startIndex),
                    let end = textView.position(from: textView.beginningOfDocument, offset: lineHighlight.rangeInSentence.endIndex),
                    let textRange = textView.textRange(from: start, to: end)
                else { continue }
                
                let rect = textView.firstRect(for: textRange)
                print("rect: \(rect)")
                
                let cellHighlight = Highlight(
                    string: "",
                    frame: rect,
                    colors: lineHighlight.colors,
                    alpha: lineHighlight.alpha
                )
                cellHighlights.insert(cellHighlight)
            }
//                cellHighlight.frame =
        }
            
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
        highlightsViewModel.update(with: cellHighlights, replace: true)
        model.resultsState?.findPhotos[index].cellHighlightsViewController = highlightsViewController
    }
    
    func didEndDisplayingResultsCell(cell: PhotosResultsCell, index: Int) {
        guard let resultsState = model.resultsState else { return }
        let findPhoto = resultsState.findPhotos[index]
        
        if let highlightsViewController = model.resultsState?.findPhotos[index].cellHighlightsViewController {
            removeChildViewController(highlightsViewController)
            model.resultsState?.findPhotos[index].cellHighlightsViewController = nil
        }
    }
}
