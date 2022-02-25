//
//  PhotosVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    func find() {
        var findPhotos = [FindPhoto]()
        for photo in model.photos {
            guard let metadata = photo.metadata else { continue }
            let (highlights, lines) = self.getHighlightsAndDescription(from: metadata.sentences)
            if highlights.count >= 1 {
                let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                let findPhoto = FindPhoto(
                    photo: photo,
                    thumbnail: thumbnail,
                    highlights: highlights,
                    descriptionText: getCellDescription(from: lines),
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
        
        
    }
    
    func getHighlightsAndDescription(from sentences: [Sentence]) -> (Set<Highlight>, [FindPhoto.Line]) {
        var highlights = Set<Highlight>()
        var lines = [FindPhoto.Line]()
        
        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = Set<FindPhoto.Line.LineHighlight>()
            
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
                    
                    let lineHighlight = FindPhoto.Line.LineHighlight(
                        rangeInSentence: index ..< index + string.count,
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
