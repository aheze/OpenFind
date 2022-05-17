//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

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

    func getResultsCount(for filter: SliderViewModel.Filter) -> Int {
        switch filter {
        case .starred:
            return starredResultsCount
        case .screenshots:
            return screenshotsResultsCount
        case .all:
            return allResultsCount
        }
    }

    func getResultsText(for filter: SliderViewModel.Filter) -> String {
        let resultsCount = getResultsCount(for: filter)

        switch resultsCount {
        case 0:
            return "No results."
        case 1:
            return "1 result in \(displayedFindPhotos.count) photos."
        default:
            return "\(resultsCount) results in \(displayedFindPhotos.count) photos."
        }
    }

    mutating func update(findPhoto: FindPhoto) {
        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.displayedFindPhotos) {
            displayedFindPhotos[index].photo = findPhoto.photo
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.allFindPhotos) {
            allFindPhotos[index].photo = findPhoto.photo
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.starredFindPhotos) {
            starredFindPhotos[index].photo = findPhoto.photo
        }

        if let index = getFindPhotoIndex(for: findPhoto.photo, in: \.screenshotsFindPhotos) {
            screenshotsFindPhotos[index].photo = findPhoto.photo
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

    func getResultsText() -> String {
        if let highlightsSet = highlightsSet {
            let highlights = highlightsSet.highlights
            switch highlights.count {
            case 0:
                return "No Results"
            case 1:
                return "1 Result"
            default:
                return "\(highlights.count) Results"
            }
        } else {
            return "No Results"
        }
    }

    func dateString() -> String {
        if let string = photo.asset.creationDate?.convertDateToReadableString() {
            return string
        } else {
            return "2022"
        }
    }

    func resultsString() -> String {
        let string: String
        if numberOfResults == 1 {
            string = "\(numberOfResults) Result"
        } else {
            string = "\(numberOfResults) Results"
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
    /// get `FindPhoto`s from specified photos, also return number of photos count
    static func findAndGetFindPhotos(
        realmModel: RealmModel,
        from photos: [Photo],
        stringToGradients: [String: Gradient]
    ) -> (
        [FindPhoto], [FindPhoto], [FindPhoto],
        Int, Int, Int
    ) {
        var allFindPhotos = [FindPhoto]()
        var starredFindPhotos = [FindPhoto]()
        var screenshotsFindPhotos = [FindPhoto]()

        var allResultsCount = 0
        var starredResultsCount = 0
        var screenshotsResultsCount = 0

        for photo in photos {
            guard let metadata = photo.metadata, !metadata.isIgnored else { continue }
            let text = realmModel.container.getText(from: metadata.assetIdentifier)
            guard let sentences = text?.sentences else { continue }

            let (lines, highlightsCount) = Finding.getLineHighlights(
                realmModel: realmModel,
                from: sentences,
                with: stringToGradients,
                imageSize: photo.asset.getSize()
            )

            if lines.count >= 1 {
                let description = Finding.getCellDescription(from: lines)

                let findPhoto = FindPhoto(
                    id: UUID(),
                    photo: photo,
                    descriptionText: description,
                    descriptionLines: lines,
                    numberOfResults: highlightsCount
                )

                allFindPhotos.append(findPhoto)

                if findPhoto.photo.isStarred {
                    starredFindPhotos.append(findPhoto)
                    starredResultsCount += highlightsCount
                }
                if findPhoto.photo.isScreenshot {
                    screenshotsFindPhotos.append(findPhoto)
                    screenshotsResultsCount += highlightsCount
                }
                allResultsCount += highlightsCount
            }
        }

        return (
            allFindPhotos, starredFindPhotos, screenshotsFindPhotos,
            allResultsCount, starredResultsCount, screenshotsResultsCount
        )
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

        for sentence in sentences {
            /// the highlights in this sentence.
            var lineHighlights = [FindPhoto.Line.LineHighlight]()

            let rangeResults = sentence.ranges(of: Array(stringToGradients.keys), realmModel: realmModel)
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
