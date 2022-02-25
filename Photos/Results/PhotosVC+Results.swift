//
//  PhotosVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 The results collection view, which should present slides as finding slides
 */

extension PhotosViewController {
    /// `removeFromSuperview` is necessary to update the large title scrolling behavior
    func showResults(_ show: Bool) {
        if show {
            if resultsCollectionView.window == nil {
                view.addSubview(resultsCollectionView)
                resultsCollectionView.pinEdgesToSuperview()
            }
            collectionView.removeFromSuperview()
            updateNavigationBlur(with: resultsCollectionView)
        } else {
            if collectionView.window == nil {
                view.addSubview(collectionView)
                collectionView.pinEdgesToSuperview()
            }
            resultsCollectionView.removeFromSuperview()
            updateNavigationBlur(with: collectionView)
            model.resultsState = nil
        }
    }

    /// get the text to show in the cell's text view
    func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }
//            .joined()
            .joined(separator: "\n")
        return string
    }
    
    func getHighlights(for cell: PhotosResultsCell, with findPhoto: FindPhoto) -> Set<Highlight> {
        var cellHighlights = Set<Highlight>()
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
                
                let frame = textView.firstRect(for: textRange)
                
                /// make sure the rectangle actually is valid
                guard frame.size.width > 0, frame.size.height > 0 else { continue }
                
                let cellHighlight = Highlight(
                    string: "",
                    frame: frame,
                    colors: lineHighlight.colors,
                    alpha: lineHighlight.alpha
                )
                cellHighlights.insert(cellHighlight)
            }
        }
        
        return cellHighlights
    }
}
