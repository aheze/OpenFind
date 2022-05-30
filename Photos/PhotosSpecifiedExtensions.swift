//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension FindPhoto {
    /// merge `FindPhoto`s and also merge the `FastDescription`

    static func merge(_ findPhotos: [FindPhoto]) -> [FindPhoto] {
        var new = [FindPhoto]()
        for findPhoto in findPhotos {
            if let firstIndex = new.firstIndex(where: { $0.photo.asset.localIdentifier == findPhoto.photo.asset.localIdentifier }) {
                if
                    let existingFastDescription = new[firstIndex].fastDescription,
                    let otherFastDescription = findPhoto.fastDescription
                {
                    let newFastDescription = FindPhoto.FastDescription(
                        containsResultsInText: existingFastDescription.containsResultsInText || otherFastDescription.containsResultsInText,
                        containsResultsInNote: existingFastDescription.containsResultsInNote || otherFastDescription.containsResultsInNote,
                        containsText: existingFastDescription.containsText || otherFastDescription.containsText,
                        containsNote: existingFastDescription.containsNote || otherFastDescription.containsNote
                    )

                    new[firstIndex].fastDescription = newFastDescription
                }
            } else {
                new.append(findPhoto)
            }
        }

        return new
    }
}

/// to update a slides photo, just get the index, then update. No need to modify `currentPhoto`, since it's just a `Photo`.
extension PhotosSlidesState {
    /// get from `findPhotos`
    func getFindPhotoIndex(findPhoto: FindPhoto) -> Int? {
        return getSlidesPhotoIndex(photo: findPhoto.photo)
    }

    /// get from `findPhotos`
    func getSlidesPhotoIndex(photo: Photo) -> Int? {
        if let firstIndex = slidesPhotos.firstIndex(where: { $0.findPhoto.photo == photo }) {
            return firstIndex
        }
        return nil
    }

    func getCurrentSlidesPhoto() -> SlidesPhoto? {
        if
            let index = getCurrentIndex(),
            let slidesPhoto = slidesPhotos[safe: index]
        {
            return slidesPhoto
        }
        return nil
    }

    /// structs may have changed, fetch from the array again
    func getUpToDateSlidesPhoto(for photo: Photo) -> SlidesPhoto? {
        if let index = getSlidesPhotoIndex(photo: photo) {
            return slidesPhotos[safe: index]
        }
        return nil
    }

    func getCurrentIndex() -> Int? {
        let index = slidesPhotos.firstIndex { $0.findPhoto.photo == currentPhoto }
        return index
    }
}

extension PhotosResultsState {
    /// get from `findPhotos`
    func getFindPhotoIndex(for photo: Photo, in keyPath: KeyPath<PhotosResultsState, [FindPhoto]>) -> Int? {
        let findPhotos = self[keyPath: keyPath]
        if let firstIndex = findPhotos.firstIndex(where: { $0.photo == photo }) {
            return firstIndex
        }
        return nil
    }

    func getResultsText() -> String {
        switch displayedFindPhotos.count {
        case 0:
            return "No results."
        case 1:
            return "\(displayedFindPhotos.count) photo."
        default:
            return "\(displayedFindPhotos.count) photos."
        }
    }

    mutating func update(findPhoto: FindPhoto) {
        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.displayedFindPhotos) {
            displayedFindPhotos[index] = findPhoto
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.allFindPhotos) {
            allFindPhotos[index] = findPhoto
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.starredFindPhotos) {
            starredFindPhotos[index] = findPhoto
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.screenshotsFindPhotos) {
            screenshotsFindPhotos[index] = findPhoto
        }
    }
}

extension FindPhoto {
    /// stores the search (`stringToGradients`) with the results (`highlights`)
    struct HighlightsSet: Equatable {
        var stringToGradients: [String: Gradient]
        var highlights: [Highlight]
    }

    struct Line: Hashable {
        var string: String
        var lineHighlights: [LineHighlight]? /// the frames of these highlights will be relative to the result cell

        struct LineHighlight: Hashable {
            var string: String
            /**
             from the start index to the end index

                Example: "Safari" - searching for "a"
                    1..<2
                    3..<4
             */
            var rangeInSentence: Range<Int>
            var colors: [UIColor]
            var alpha: CGFloat
        }
    }

    func getResultsString() -> String {
        switch description?.numberOfResults ?? 0 {
        case 0:
            return "No results"
        case 1:
            return "1 result"
        default:
            return "\(description?.numberOfResults ?? 0) results"
        }
    }

    func dateString() -> String {
        if let string = photo.asset.creationDate?.convertDateToReadableString() {
            return string
        } else {
            return "2022"
        }
    }
}

extension FindPhoto.Description {
    var numberOfResults: Int {
        return numberOfResultsInNote + numberOfResultsInText
    }

    func resultsString() -> String {
        let string: String

        if numberOfResults == 1 {
            string = "\(numberOfResults) result"
        } else {
            string = "\(numberOfResults) results"
        }

        return string
    }
}

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

        if let description = description {
            if description.numberOfResults == 1 {
                resultsText = " \(description.numberOfResults) result. \(description.text)"
            } else {
                resultsText = " \(description.numberOfResults) results. \(description.text)"
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
    /// get `FindPhoto`s from specified photos
    static func findAndGetFindPhotos(
        realmModel: RealmModel,
        from photos: [Photo],
        stringToGradients: [String: Gradient],
        scope: PhotosSearchScope
    ) -> (
        [FindPhoto], [FindPhoto], [FindPhoto]
    ) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()

        for photo in photos {
            let contains: Bool
            var fastDescription = FindPhoto.FastDescription()

            guard let metadata = photo.metadata else { continue }
            let search = Array(stringToGradients.keys)

            switch scope {
            case .text:

                guard !metadata.isIgnored else { continue }
                let text = realmModel.container.getText(from: metadata.assetIdentifier)
                guard let sentences = text?.sentences else { continue }

                /// very fast!
                contains = sentences.checkIf(realmModel: realmModel, matches: search)
                fastDescription.containsNote = realmModel.container.checkNoteExists(assetIdentifier: metadata.assetIdentifier)
                fastDescription.containsText = true
                fastDescription.containsResultsInText = contains
            case .note:
                guard let note = realmModel.container.getNote(from: metadata.assetIdentifier), !note.string.isEmpty else { continue }
                contains = Finding.checkIf(realmModel: realmModel, stringToSearchFrom: note.string, matches: search)
                fastDescription.containsNote = true
                fastDescription.containsResultsInNote = contains
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
        from sentences: [Sentence],
        with stringToGradients: [String: Gradient],
        imageSize: CGSize?
    ) -> ([FindPhoto.Line], Int) {
        var lines = [FindPhoto.Line]()
        var highlightsCount = 0

        let strings = Array(stringToGradients.keys)

        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = [FindPhoto.Line.LineHighlight]()

            let rangeResults = sentence.ranges(of: strings, realmModel: realmModel)
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
                let line = FindPhoto.Line(string: sentence.string, lineHighlights: lineHighlights)
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

extension Array where Element == Photo {
    /// apply metadata to a single photo inside an array of photos
    /// only modify the changed properties `dateScanned` and `sentences`
    mutating func applyMetadata(at index: Int, with metadata: PhotoMetadata?) {
        if self[index].metadata != nil {
            self[index].metadata?.dateScanned = metadata?.dateScanned
        } else {
            self[index].metadata = metadata
        }
    }
}

extension Array where Element == FindPhoto {
    mutating func applyMetadata(at index: Int, with metadata: PhotoMetadata?) {
        if self[index].photo.metadata != nil {
            self[index].photo.metadata?.dateScanned = metadata?.dateScanned
        } else {
            self[index].photo.metadata = metadata
        }
    }
}

extension Array where Element == SlidesPhoto {
    mutating func applyMetadata(at index: Int, with metadata: PhotoMetadata?) {
        if self[index].findPhoto.photo.metadata != nil {
            self[index].findPhoto.photo.metadata?.dateScanned = metadata?.dateScanned
        } else {
            self[index].findPhoto.photo.metadata = metadata
        }
    }
}
