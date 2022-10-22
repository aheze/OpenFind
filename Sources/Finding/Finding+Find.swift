//
//  PhotosFinding.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension Finding {
    /// get `FindPhoto`s from specified photos
    static func findAndGetFindPhotos(
        realmModel: RealmModel,
        from photos: [Photo],
        stringToGradients: [String: Gradient]
    ) -> (
        [FindPhoto], [FindPhoto], [FindPhoto]
    ) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()

        for photo in photos {
            var contains = false
            var fastDescription = FindPhoto.FastDescription()

            guard let metadata = photo.metadata else { continue }
            let search = Array(stringToGradients.keys)

            if !metadata.isIgnored {
                let text = realmModel.container.getText(from: metadata.assetIdentifier)
                if let sentences = text?.sentences {
                    /// very fast!
                    let containsResultsInText = sentences.checkIf(realmModel: realmModel, matches: search)
                    fastDescription.containsText = true
                    fastDescription.containsResultsInText = containsResultsInText

                    if !contains {
                        contains = containsResultsInText
                    }
                }
            }

            if let note = realmModel.container.getNote(from: metadata.assetIdentifier), !note.string.isEmpty {
                let containsResultsInNote = Finding.checkIf(realmModel: realmModel, stringToSearchFrom: note.string, matches: search)
                fastDescription.containsNote = true
                fastDescription.containsResultsInNote = containsResultsInNote

                /// set contains if haven't set before
                if !contains {
                    contains = containsResultsInNote
                }
            }

            if contains {
                let findPhoto = FindPhoto(
                    photo: photo,
                    fastDescription: fastDescription
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

        return (allFindPhotos, starredFindPhotos, screenshotsFindPhotos)
    }

    /// return lines and also number of highlights
    static func getLineHighlights(
        realmModel: RealmModel,
        from sentences: RealmSwift.List<RealmSentence>,
        with stringToGradients: [String: Gradient],
        imageSize: CGSize?
    ) -> ([FindPhoto.Line], Int) {
        var lines = [FindPhoto.Line]()
        var highlightsCount = 0

        let strings = Array(stringToGradients.keys)

        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = [FindPhoto.Line.LineHighlight]()

            let rangeResults = sentence.getSentence().ranges(of: strings, realmModel: realmModel)
            for rangeResult in rangeResults {
                let gradient = stringToGradients[rangeResult.string] ?? Gradient()
                for range in rangeResult.ranges {
                    highlightsCount += 1
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
                guard let string = sentence.string else { continue }
                let line = FindPhoto.Line(string: string, lineHighlights: lineHighlights)
                lines.append(line)
            }
        }

        return (lines, highlightsCount)
    }

    /// get the text to show in the cell's text view
    static func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }.joined(separator: "\n")
        return string
    }
}
