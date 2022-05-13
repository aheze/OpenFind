//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotoMetadata {
    static func apply(metadata: PhotoMetadata?, to view: PhotosCellView) {
        if let metadata = metadata {
            if metadata.isIgnored {
                view.shadeView.alpha = 1
            } else {
                view.shadeView.alpha = 0
            }
            if metadata.isStarred {
                view.overlayGradientImageView.alpha = 1
                view.overlayStarImageView.alpha = 1
            } else {
                view.overlayGradientImageView.alpha = 0
                view.overlayStarImageView.alpha = 0
            }

            /// make set to reset if metadata doesn't exist - cells get reused
        } else {
            view.shadeView.alpha = 0
            view.overlayGradientImageView.alpha = 0
            view.overlayStarImageView.alpha = 0
        }
    }
}

extension Photo {
    func getVoiceoverDescription() -> String {
        let dateString = asset.creationDate?.convertDateToReadableString() ?? ""
        let timeString = asset.timeCreatedString ?? ""
        let creationString = "\(dateString) at \(timeString)"
        
        let starred = metadata?.isStarred ?? false
        
        if starred {
            return "\(creationString), starred."
        } else {
            return creationString
        }
    }
}

extension FindPhoto {
    func getVoiceoverDescription() -> String {
        let photoDescription = photo.getVoiceoverDescription()
        var resultsText = ""
        
        if let highlightsSet = highlightsSet {
            if highlightsSet.highlights.count == 1 {
                resultsText = " \(highlightsSet.highlights.count) result. \(descriptionText)"
            } else {
                resultsText = " \(highlightsSet.highlights.count) results. \(descriptionText)"
            }
        }
        
        let string = photoDescription + resultsText
        return string
    }
}

extension PHAsset {
    func getDateCreatedCategorization() -> PhotosSectionCategorization? {
        if
            let components = creationDate?.get(.year, .month),
            let year = components.year, let month = components.month
        {
            let categorization = PhotosSectionCategorization.date(year: year, month: month)
            return categorization
        }
        return nil
    }
}

extension Finding {
    /// get FindPhotos from specified photos
    static func findAndGetFindPhotos(realmModel: RealmModel, from photos: [Photo], stringToGradients: [String: Gradient]) -> ([FindPhoto], [FindPhoto], [FindPhoto]) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()
        
        print("Starting: \(stringToGradients.keys)")
        let timer = TimeElapsed()
        
//        var text: PhotoMetadataText?
//        if let metadata = photos.first?.metadata {
//            text = realmModel.container.getText(from: metadata.assetIdentifier)
//        }
//
        for photo in photos {
            guard let metadata = photo.metadata, !metadata.isIgnored else { continue }
//            print("Looping.")
            let text = realmModel.container.getText(from: metadata.assetIdentifier)
//            let text: PhotoMetadataText? = PhotoMetadataText()
            
            let (highlights, lines) = Finding.getHighlightsAndDescription(
                realmModel: realmModel,
                from: [],
                with: stringToGradients,
                imageSize: photo.asset.getSize()
            )
//            let (highlights, lines) = Finding.getHighlightsAndDescription(
//                realmModel: realmModel,
//                from: text?.sentences ?? [],
//                with: stringToGradients,
//                imageSize: photo.asset.getSize()
//            )
            
            if highlights.count >= 1 {
                let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: stringToGradients, highlights: highlights)
                let description = Finding.getCellDescription(from: lines)
                
                let findPhoto = FindPhoto(
                    id: UUID(),
                    photo: photo,
                    highlightsSet: highlightsSet,
                    descriptionText: description,
                    descriptionLines: lines
                )
            
                allFindPhotos.append(findPhoto)
                
                if findPhoto.photo.isStarred {
                    starredFindPhotos.append(findPhoto)
                }
                if findPhoto.photo.isScreenshot {
                    screenshotsFindPhotos.append(findPhoto)
                }
            }
        }
        
        print("     Ending: \(stringToGradients.keys). \(timer.stop())")

        return (allFindPhotos, starredFindPhotos, screenshotsFindPhotos)
    }
    
    static func getHighlightsAndDescription(
        realmModel: RealmModel,
        from sentences: [Sentence],
        with stringToGradients: [String: Gradient],
        imageSize: CGSize?
    ) -> ([Highlight], [FindPhoto.Line]) {
        var highlights = [Highlight]()
        var lines = [FindPhoto.Line]()
        
        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = [FindPhoto.Line.LineHighlight]()
            
            let rangeResults = sentence.ranges(of: Array(stringToGradients.keys), realmModel: realmModel)
            for rangeResult in rangeResults {
                let gradient = stringToGradients[rangeResult.string] ?? Gradient()
                for range in rangeResult.ranges {
                    let highlight = Highlight(
                        string: rangeResult.string,
                        colors: gradient.colors,
                        alpha: gradient.alpha,
                        position: sentence.getPosition(
                            for: range,
                            imageSize: imageSize
                        )
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
    
    /// get the text to show in the cell's text view
    static func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }.joined(separator: "\n")
        return string
    }
}
