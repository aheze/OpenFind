//
//  PhotosVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    /// find in all photos and populate `resultsState`
    func find() {
        var findPhotos = [FindPhoto]()
        for photo in model.photos {
            guard let metadata = photo.metadata, !metadata.isIgnored else { continue }
            let (highlights, lines) = self.getHighlightsAndDescription(from: metadata.sentences, with: self.searchViewModel.stringToGradients)
            if highlights.count >= 1 {
                let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.searchViewModel.stringToGradients, highlights: highlights)
                let description = getCellDescription(from: lines)
                
                let findPhoto = FindPhoto(
                    id: UUID(),
                    photo: photo,
                    thumbnail: thumbnail,
                    highlightsSet: highlightsSet,
                    descriptionText: description,
                    descriptionLines: lines
                )
            
                findPhotos.append(findPhoto)
            }
        }
        
        if model.resultsState != nil {
            model.resultsState = PhotosResultsState(findPhotos: findPhotos)
            updateResults(animate: true)
        } else {
            model.resultsState = PhotosResultsState(findPhotos: findPhotos)
            updateResults(animate: false)
            if model.isSelecting {
                resetSelectingState()
                updateCollectionViewSelectionState()
            }
        }
        
        self.resultsHeaderViewModel.text = self.model.resultsState?.getResultsText() ?? ""
    }
    
    
    func getHighlightsAndDescription(
        from sentences: [Sentence],
        with stringToGradients: [String: Gradient]
    ) -> (Set<Highlight>, [FindPhoto.Line]) {
        var highlights = Set<Highlight>()
        var lines = [FindPhoto.Line]()
        
        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = Set<FindPhoto.Line.LineHighlight>()
            
            let rangeResults = sentence.ranges(of: Array(stringToGradients.keys))
            for rangeResult in rangeResults {
                let gradient = self.searchViewModel.stringToGradients[rangeResult.string] ?? Gradient()
                for range in rangeResult.ranges {
                    let highlight = Highlight(
                        string: rangeResult.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: sentence.position(for: range)
                    )

                    highlights.insert(highlight)
                        
                    let lineHighlight = FindPhoto.Line.LineHighlight(
                        string: rangeResult.string,
                        rangeInSentence: range,
                        colors: gradient.colors,
                        alpha: gradient.alpha
                    )
                    lineHighlights.insert(lineHighlight)
                }
            }
            
            if lineHighlights.count > 0 {
                let line = FindPhoto.Line(string: sentence.string, lineHighlights: lineHighlights)
                lines.append(line)
            }
        }
        
        return (highlights, lines)
    }
}
