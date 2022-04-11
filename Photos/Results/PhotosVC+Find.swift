//
//  PhotosVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// control how to find
enum FindContext {
    case findingAfterNewPhotosAdded
    case findingAfterTextChange
    
    /// no need to scan again if:
    ///     - photo starred/unstarred
    ///     - photo added via live results
    case justFindFromExistingDoNotScan
}

extension PhotosViewController {
    
    /// call `findAndUpdateResultsState` and reload the collection views
    func findAndUpdateDisplayedPhotos(context: FindContext) {
        if model.resultsState != nil {
            self.findAndUpdateResultsState(context: context) /// find again (handles star/unstar)
        }

        switch sliderViewModel.selectedFilter ?? .all {
        case .starred:
            model.displayedSections = model.starredSections
        case .screenshots:
            model.displayedSections = model.screenshotsSections
        case .all:
            model.displayedSections = model.allSections
        }

        update()
        updateResults()
    }
    
    /// find in all photos and populate `resultsState`
    func findAndUpdateResultsState(context: FindContext) {
        if !model.photosToScan.isEmpty, model.scanningState == .dormant {
            switch context {
            case .findingAfterNewPhotosAdded:
                if realmModel.photosScanOnAddition {
                    model.startScanning()
                }
            case .findingAfterTextChange:
                if realmModel.photosScanOnFind {
                    model.startScanning()
                }
            case .justFindFromExistingDoNotScan:
                break
            }
        }
        
        let displayedFindPhotos: [FindPhoto]
        let (allFindPhotos, starredFindPhotos, screenshotsFindPhotos) = self.findAndGetFindPhotos(from: model.photos)
        
        switch sliderViewModel.selectedFilter ?? .all {
        case .starred:
            displayedFindPhotos = starredFindPhotos
        case .screenshots:
            displayedFindPhotos = screenshotsFindPhotos
        case .all:
            displayedFindPhotos = allFindPhotos
        }
        
        model.resultsState = PhotosResultsState(
            displayedFindPhotos: displayedFindPhotos,
            allFindPhotos: allFindPhotos,
            starredFindPhotos: starredFindPhotos,
            screenshotsFindPhotos: screenshotsFindPhotos
        )
    }
    
    /// get FindPhotos from specified photos
    func findAndGetFindPhotos(from photos: [Photo]) -> ([FindPhoto], [FindPhoto], [FindPhoto]) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()
        
        for photo in photos {
            guard let metadata = photo.metadata, !metadata.isIgnored else { continue }
            let (highlights, lines) = self.getHighlightsAndDescription(from: metadata.sentences, with: self.searchViewModel.stringToGradients)
            if highlights.count >= 1 {
                let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.searchViewModel.stringToGradients, highlights: highlights)
                let description = getCellDescription(from: lines)
                
                let findPhoto = FindPhoto(
                    id: UUID(),
                    photo: photo,
                    highlightsSet: highlightsSet,
                    descriptionText: description,
                    descriptionLines: lines
                )
            
                allFindPhotos.append(findPhoto)
                
                if findPhoto.photo.isStarred() {
                    starredFindPhotos.append(findPhoto)
                }
                if findPhoto.photo.isScreenshot() {
                    screenshotsFindPhotos.append(findPhoto)
                }
            }
        }
        
        return (allFindPhotos, starredFindPhotos, screenshotsFindPhotos)
    }
    
    func getHighlightsAndDescription(
        from sentences: [Sentence],
        with stringToGradients: [String: Gradient]
    ) -> ([Highlight], [FindPhoto.Line]) {
        var highlights = [Highlight]()
        var lines = [FindPhoto.Line]()
        
        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = [FindPhoto.Line.LineHighlight]()
            
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

                    highlights.append(highlight)
                        
                    let lineHighlight = FindPhoto.Line.LineHighlight(
                        string: rangeResult.string,
                        rangeInSentence: range,
                        colors: gradient.colors,
                        alpha: gradient.alpha
                    )
                    lineHighlights.append(lineHighlight)
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
