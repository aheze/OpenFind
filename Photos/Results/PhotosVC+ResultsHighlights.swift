//
//  PhotosVC+ResultsHighlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    /// call this inside the cell provider. Frames of returned highlights are already scaled.
    func getHighlights(for cell: PhotosResultsCell, with lines: [FindPhoto.Line]) -> [Highlight] {
        /// the highlights to be shown. Create these from `lineHighlights`
        var cellHighlights = [Highlight]()
        for index in lines.indices {
            let line = lines[index]
            
            /// `lineHighlights` - highlights in the cell without a frame - only represented by their ranges
            guard
                let lineHighlights = line.lineHighlights,
                let textView = cell.descriptionTextView
            else { continue }
            
            let previousLines = Array(lines.prefix(index))
            let previousDescription = Finding.getCellDescription(from: previousLines)
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
                    id: UUID(),
                    string: lineHighlight.string,
                    colors: lineHighlight.colors,
                    alpha: lineHighlight.alpha,
                    position: .init(
                        center: frame.center,
                        size: frame.size,
                        angle: .zero
                    )
                )
                cellHighlights.append(cellHighlight)
            }
        }
        
        return cellHighlights
    }

    /// replace the `resultsState`'s current highlight colors. Don't call `update()`, since applying snapshots is laggy.
    /// This only updates the results collection view.
    /// This also resets each `FindPhoto`'s `HighlightsSet` to a single highlight set with the new colors.
    func updateResultsHighlightColors() {
        guard tabViewModel.tabState == .photos else { return }

        if let resultsState = model.resultsState {
            for index in resultsState.displayedFindPhotos.indices {
                if
                    let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell,
                    let viewController = cell.highlightsViewController
                {
                    let currentHighlights = viewController.highlightsViewModel.highlights
                    var newHighlights = [Highlight]()
                    for highlight in currentHighlights {
                        if let gradient = searchViewModel.stringToGradients[highlight.string] {
                            var newHighlight = highlight
                            newHighlight.colors = gradient.colors
                            newHighlight.alpha = gradient.alpha
                            newHighlights.append(newHighlight)
                        }
                    }
                    
                    cell.highlightsViewController?.highlightsViewModel.highlights = newHighlights
                }
            }
        }
    }
}

extension PhotosViewController {
    /// populate the cell with actual finding data
    func configureResultsCellDescription(cell: PhotosResultsCell, findPhoto: FindPhoto) {
        var description: FindPhoto.Description
        if let existingDescription = findPhoto.description {
            description = existingDescription
        } else {
            let (lines, highlightsCount) = Finding.getLineHighlights(
                realmModel: realmModel,
                from: realmModel.container.getText(from: findPhoto.photo.asset.localIdentifier)?.sentences ?? [],
                with: searchViewModel.stringToGradients,
                imageSize: findPhoto.photo.asset.getSize()
            )
            
            let text = Finding.getCellDescription(from: lines)
            description = .init(numberOfResults: highlightsCount, text: text, lines: lines)
        }
        
        cell.resultsLabel.text = description.resultsString()
        cell.descriptionTextView.text = description.text
        
        var newFindPhoto = findPhoto
        newFindPhoto.description = description
        model.resultsState?.update(findPhoto: newFindPhoto)
        cell.accessibilityLabel = newFindPhoto.getVoiceoverDescription()
        
        loadHighlights(for: cell, lines: description.lines)
    }
    
    /// add the highlights for a results cell
    func loadHighlights(for cell: PhotosResultsCell, lines: [FindPhoto.Line]) {
        /// clear existing highlights
        
        var highlightsViewController: HighlightsViewController
        if let existingHighlightsViewController = cell.highlightsViewController {
            highlightsViewController = existingHighlightsViewController
        } else {
            let highlightsViewModel = HighlightsViewModel()
            highlightsViewModel.shouldScaleHighlights = false /// highlights are already scaled
            let newHighlightsViewController = HighlightsViewController(
                highlightsViewModel: highlightsViewModel,
                realmModel: realmModel
            )
            addChildViewController(newHighlightsViewController, in: cell.descriptionHighlightsContainerView)
            cell.highlightsViewController = newHighlightsViewController
            highlightsViewController = newHighlightsViewController
        }
        
        highlightsViewController.view.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.1) {
                cell.highlightsViewController?.view.alpha = 1
            }
            highlightsViewController.highlightsViewModel.highlights = self.getHighlights(for: cell, with: lines)
        }
    }
}
