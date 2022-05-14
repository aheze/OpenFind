//
//  PhotosModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct SlidesPhoto: Hashable {
    var id = UUID()
    var findPhoto: FindPhoto

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PhotosSlidesState {
    var viewController: PhotosSlidesViewController?
    var slidesPhotos: [SlidesPhoto]
    var currentPhoto: Photo?

    var isFullScreen = false /// hide the bars

    /// for the current image
    var toolbarStarOn = false
    var toolbarInformationOn = false

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

enum PhotosSentencesUpdateState {
    case scheduled
    case waitingForPermission
}

struct PhotosResultsState {
    var displayedFindPhotos: [FindPhoto]

    var allFindPhotos: [FindPhoto]
    var starredFindPhotos: [FindPhoto]
    var screenshotsFindPhotos: [FindPhoto]

    var allResultsCount: Int
    var starredResultsCount: Int
    var screenshotsResultsCount: Int

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

/// a photo that contains results to display (in the form of highlights)
struct FindPhoto: Hashable {
    var id: UUID
    var photo: Photo

    /// results (an array of highlights)
    var highlightsSet: HighlightsSet?
    var descriptionText = ""
    var descriptionLines = [Line]()
    var numberOfResults = 0

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

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
}

extension FindPhoto {
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

struct PhotosSection: Hashable {
    var title: String
    var categorization: PhotosSectionCategorization
    var photos = [Photo]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(categorization)
    }

    static func == (lhs: PhotosSection, rhs: PhotosSection) -> Bool {
        lhs.categorization == rhs.categorization
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
