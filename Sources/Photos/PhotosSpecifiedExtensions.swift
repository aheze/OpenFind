//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension Array where Element == FindPhoto {
    /// check `FastDescription`
    func filterHasResults() -> [FindPhoto] {
        filter { findPhoto in
            if let fastDescription = findPhoto.fastDescription {
                return fastDescription.containsResultsInText || fastDescription.containsResultsInNote
            }
            return false
        }
    }

    func filterHasNotesResults() -> [FindPhoto] {
        filter { findPhoto in
            if let fastDescription = findPhoto.fastDescription {
                return fastDescription.containsResultsInNote
            }
            return false
        }
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
