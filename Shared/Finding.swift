//
//  Finding.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

enum Finding {
    /// check if a string matches the search (the string contains at least one of the searches)
    static func checkIf(realmModel: RealmModel, string: String, matches search: [String]) -> Bool {
        let stringToSearchFrom = string.applyDefaults(realmModel: realmModel)
        return search.contains { text in
            let stringToSearch = text.applyDefaults(realmModel: realmModel)
            return stringToSearchFrom.contains(stringToSearch)
        }
    }

    static func checkIf(realmModel: RealmModel, string: String, contains text: String) -> Bool {
        let stringToSearchFrom = string.applyDefaults(realmModel: realmModel)
        let stringToSearch = text.applyDefaults(realmModel: realmModel)
        return stringToSearchFrom.contains(stringToSearch)
    }
    
    /// get FindPhotos from specified photos
    static func findAndGetFindPhotos(realmModel: RealmModel, from photos: [Photo], stringToGradients: [String: Gradient]) async -> ([FindPhoto], [FindPhoto], [FindPhoto]) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()
        
        for photo in photos {
            guard let metadata = photo.metadata, !metadata.isIgnored else { continue }
            let (highlights, lines) = Finding.getHighlightsAndDescription(
                realmModel: realmModel,
                from: metadata.sentences,
                with: stringToGradients
            )
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
    
    static func getHighlightsAndDescription(
        realmModel: RealmModel,
        from sentences: [Sentence],
        with stringToGradients: [String: Gradient]
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
    
    /// get the text to show in the cell's text view
    static func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }.joined(separator: "\n")
        return string
    }
}

extension String {
    /// apply `findingMatchCase` and `findingMatchAccents` to a string
    func applyDefaults(realmModel: RealmModel) -> String {
        var string = self
        if !realmModel.findingMatchCase {
            string = string.lowercased()
        }
        if !realmModel.findingMatchAccents {
            string = string.folding(options: .diacriticInsensitive, locale: .current)
        }
        return string
    }
}
