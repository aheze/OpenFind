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
        print("Will display at \(index).")
        guard
            let resultsState = model.resultsState,
            let findPhoto = resultsState.findPhotos[safe: index]
        else { return }
        
        let highlightsViewModel = HighlightsViewModel()
            
        var cellHighlights = Set<Highlight>()
        
        print("->>    Lines: \(findPhoto.descriptionLines.map { $0.string })")
        for index in findPhoto.descriptionLines.indices {
            let line = findPhoto.descriptionLines[index]
            guard
                let lineHighlights = line.lineHighlights,
                let textView = cell.descriptionTextView
            else { continue }
            

            let previousLines = Array(findPhoto.descriptionLines.prefix(index))
            let previousDescription = getCellDescription(from: previousLines)
            
            let previousDescriptionCount = previousDescription.count
            
            for lineHighlight in lineHighlights {

                textView.layoutManager.ensureLayout(for: textView.textContainer)
                guard
                    let start = textView.position(from: textView.beginningOfDocument, offset: lineHighlight.rangeInSentence.startIndex + previousDescriptionCount),
                    let end = textView.position(from: textView.beginningOfDocument, offset: lineHighlight.rangeInSentence.endIndex + previousDescriptionCount),
                    let textRange = textView.textRange(from: start, to: end)
                else { continue }
                
                let rect = textView.firstRect(for: textRange)
                
                print("     rect: \(rect)")
                
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
        
        print("     Highlights for \(index): \(cellHighlights.count)")
        highlightsViewModel.highlights = cellHighlights
//        highlightsViewModel.update(with: cellHighlights, replace: true)
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
        model.resultsState?.findPhotos[index].cellHighlightsViewController = highlightsViewController
    }
    
    func didEndDisplayingResultsCell(cell: PhotosResultsCell, index: Int) {
        print("             Did end displaying at \(index)")
        guard let resultsState = model.resultsState else { return }
        if
            let findPhoto = resultsState.findPhotos[safe: index],
            let highlightsViewController = model.resultsState?.findPhotos[index].cellHighlightsViewController
        {
            removeChildViewController(highlightsViewController)
            model.resultsState?.findPhotos[index].cellHighlightsViewController = nil
        }
    }
}
