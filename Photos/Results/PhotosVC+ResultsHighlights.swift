//
//  PhotosVC+ResultsHighlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    /// populate the cell with actual finding data and highlights
    func configureCellResultsDescription(cell: PhotosCellResults, findPhoto: FindPhoto) {
        guard let viewController = cell.viewController else { return }
        
        if let note = realmModel.container.getNote(from: findPhoto.photo.asset.localIdentifier) {
            viewController.resultsModel.note = note.string
        } else {
            viewController.resultsModel.note = nil
        }
        
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let highlights = self.getLineHighlights(for: cell, with: lines)
                viewController.highlightsViewModel.update(with: highlights, replace: true)
            }
        }
        
        viewController.resultsModel.resultsText = description.resultsString()
        viewController.resultsModel.text = description.text
        
        var newFindPhoto = findPhoto
        newFindPhoto.description = description
        model.resultsState?.update(findPhoto: newFindPhoto)
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = newFindPhoto.getVoiceoverDescription()
    }
}

extension PhotosViewController {
    /// call this inside the cell provider. Frames of returned highlights are already scaled.
    func getLineHighlights(for cell: PhotosCellResults, with lines: [FindPhoto.Line]) -> [Highlight] {
        /// the highlights to be shown. Create these from `lineHighlights`
        var cellHighlights = [Highlight]()
        
        /// don't loop too many times
        for index in lines.indices where index < 3 {
            let line = lines[index]
            
            /// `lineHighlights` - highlights in the cell without a frame - only represented by their ranges
            guard
                let lineHighlights = line.lineHighlights,
                let getFrameForRange = cell.viewController?.textModel.getFrameForRange
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
                
                guard let frame = getFrameForRange(startOffset, endOffset) else { continue }
                
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
                    let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosCellResults,
                    let highlightsViewModel = cell.viewController?.highlightsViewModel
                {
                    var newHighlights = [Highlight]()
                    for highlight in highlightsViewModel.highlights {
                        if let gradient = searchViewModel.stringToGradients[highlight.string] {
                            var newHighlight = highlight
                            newHighlight.colors = gradient.colors
                            newHighlight.alpha = gradient.alpha
                            newHighlights.append(newHighlight)
                        }
                    }
                    
                    highlightsViewModel.highlights = newHighlights
                }
            }
        }
    }
}

extension UITextView {
    /// get the frame of a range
    func getFrame(start startOffset: Int, end endOffset: Int) -> CGRect? {
        if
            let start = position(from: beginningOfDocument, offset: startOffset),
            let end = position(from: beginningOfDocument, offset: endOffset),
            let textRange = textRange(from: start, to: end)
        {
            let frame = firstRect(for: textRange)
            return frame
        }
        return nil
    }
}
