//
//  PhotosVM+Delete.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewModel {
    /// refresh collection view and results collection view models, not slides
    func refreshCollectionViews(afterDeleting photos: [Photo]) {
        self.photos = self.photos.filter { !photos.contains($0) }

        deletePhotos(deletedPhotos: photos, in: &displayedSections)
        deletePhotos(deletedPhotos: photos, in: &allSections)
        deletePhotos(deletedPhotos: photos, in: &starredSections)
        deletePhotos(deletedPhotos: photos, in: &screenshotsSections)
        if resultsState != nil {
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.displayedFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.allFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.starredFindPhotos)
            deletePhotos(deletedPhotos: photos, in: \PhotosResultsState.screenshotsFindPhotos)
        }
    }

    func deletePhotos(deletedPhotos: [Photo], in sections: inout [PhotosSection]) {
        var newSections = [PhotosSection]()
        for sectionIndex in sections.indices {
            var section = sections[sectionIndex]
            let photos = section.photos.filter { !deletedPhotos.contains($0) }
            section.photos = photos
            newSections.append(section)
        }
        let filteredSections = newSections.filter { !$0.photos.isEmpty }
        sections = filteredSections
    }

    func deletePhotos(deletedPhotos: [Photo], in keyPath: WritableKeyPath<PhotosResultsState, [FindPhoto]>) {
        let photos = resultsState?[keyPath: keyPath].filter { !deletedPhotos.contains($0.photo) } ?? []
        resultsState?[keyPath: keyPath] = photos
    }

    func deletePhotos(deletedPhotos: [Photo], in keyPath: WritableKeyPath<PhotosSlidesState, [FindPhoto]>) {
        let photos = slidesState?[keyPath: keyPath].filter { !deletedPhotos.contains($0.photo) } ?? []
        slidesState?[keyPath: keyPath] = photos
    }
}
