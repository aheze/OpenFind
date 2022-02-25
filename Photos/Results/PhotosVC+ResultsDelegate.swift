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
        guard
            let resultsState = model.resultsState,
            let findPhoto = resultsState.findPhotos[safe: index]
        else { return }
        
//        print("Will display at \(index) (\(findPhoto.dateString()))")
        
        let highlightsViewModel = HighlightsViewModel()
            
        var cellHighlights = Set<Highlight>()
        
//        print("->>    Lines: \(findPhoto.descriptionLines.map { $0.string })")
        for index in findPhoto.descriptionLines.indices {
            let line = findPhoto.descriptionLines[index]
            guard
                let lineHighlights = line.lineHighlights,
                let textView = cell.descriptionTextView
            else { continue }
            
            let previousLines = Array(findPhoto.descriptionLines.prefix(index))
            let previousDescription = getCellDescription(from: previousLines)
            var previousDescriptionCount = previousDescription.count
            
            /// Needed to account for newLines - otherwise every line after the first will have highlights shifted 1 to the left
            if previousDescriptionCount > 0 {
                previousDescriptionCount += 1
            }
            
            for lineHighlight in lineHighlights {
                let startOffset = lineHighlight.rangeInSentence.startIndex + previousDescriptionCount
                let endOffset = lineHighlight.rangeInSentence.endIndex + previousDescriptionCount
                
                guard
                    let start = textView.position(from: textView.beginningOfDocument, offset: startOffset),
                    let end = textView.position(from: textView.beginningOfDocument, offset: endOffset),
                    let textRange = textView.textRange(from: start, to: end)
                else { continue }
                
                let rect = textView.firstRect(for: textRange)
                
//                print("     [original: \(lineHighlight.rangeInSentence)] + \(previousDescriptionCount) = [new: \(startOffset)..<\(endOffset)] -> rect: \(rect)")
                
                let cellHighlight = Highlight(
                    string: "",
                    frame: rect,
                    colors: lineHighlight.colors,
                    alpha: lineHighlight.alpha
                )
                cellHighlights.insert(cellHighlight)
            }
        }
        
//        print("     Highlights for \(index): \(cellHighlights.count)")
        
        highlightsViewModel.highlights = cellHighlights
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
        model.resultsState?.findPhotos[index].cellHighlightsViewController = highlightsViewController
    }
    
    func didEndDisplayingResultsCell(cell: PhotosResultsCell, index: Int) {
        print("             Did end displaying at \(index)")
        if let highlightsViewController = model.resultsState?.findPhotos[index].cellHighlightsViewController {
            print("Reoving \(highlightsViewController).")
            removeChildViewController(highlightsViewController)
            model.resultsState?.findPhotos[index].cellHighlightsViewController = nil
        }
    }
}
