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
            guard let metadata = photo.metadata else { continue }
            let (highlights, lines) = self.getHighlightsAndDescription(from: metadata.sentences)
            if highlights.count >= 1 {
                let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                let description = getCellDescription(from: lines)
                
                let findPhoto = FindPhoto(
                    photo: photo,
                    thumbnail: thumbnail,
                    highlights: highlights,
                    descriptionText: description,
                    descriptionLines: lines
                )
            
                findPhotos.append(findPhoto)
            }
        }
        
        if self.model.resultsState != nil {
            self.model.resultsState = PhotosResultsState(findPhotos: findPhotos)
            self.updateResults(animate: true)
        } else {
            self.model.resultsState = PhotosResultsState(findPhotos: findPhotos)
            self.updateResults(animate: false)
        }
        
        self.slidesSearchPromptViewModel.show = true
        self.slidesSearchPromptViewModel.resultsText = "Hello!"
    }
    
    func getHighlightsAndDescription(from sentences: [Sentence]) -> (Set<Highlight>, [FindPhoto.Line]) {
        var highlights = Set<Highlight>()
        var lines = [FindPhoto.Line]()
        
        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = Set<FindPhoto.Line.LineHighlight>()
            
            let rangeResults = sentence.ranges(of: Array(self.searchViewModel.stringToGradients.keys))
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
