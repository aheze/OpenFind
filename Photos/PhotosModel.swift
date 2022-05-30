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
}

/// what part of the image to search in
enum PhotosSearchScope {
    case text
    case note
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

    /// recalculated after bounds change
    var displayedCellSizes = [CGSize]()
}

/// a photo that contains results to display (in the form of highlights)
struct FindPhoto: Hashable {
    var photo: Photo

    /// results (an array of highlights)
    var highlightsSet: HighlightsSet?

    /// for calculating cell sizes
    /// set this in `find()`
    var fastDescription: FastDescription?

    var description: Description? /// contains everything to be displayed

    func hash(into hasher: inout Hasher) {
        hasher.combine(photo.asset)
    }

    static func == (lhs: FindPhoto, rhs: FindPhoto) -> Bool {
        lhs.photo.asset == rhs.photo.asset
    }

    struct FastDescription {
        var containsResultsInText = false
        var containsResultsInNote = false

        /// just for showing
        var containsText = false
        var containsNote = false
    }

    struct Description {
        var text = ""
        var lines = [Line]()
        var numberOfResultsInText = 0
        var note: String?
        var numberOfResultsInNote = 0
    }

    mutating func createDescriptionIfNeeded() {
        if description == nil {
            description = .init()
        }
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
