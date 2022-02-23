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
            let highlights = self.getHighlights(from: metadata.sentences)
            if highlights.count >= 1 {
                let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                let findPhoto = FindPhoto(
                    photo: photo,
                    thumbnail: thumbnail,
                    highlights: highlights
                )
            
                findPhotos.append(findPhoto)
            }
        }
        self.model.resultsState = PhotosResultsState(findPhotos: findPhotos)
        updateResults(animate: true)
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
}
