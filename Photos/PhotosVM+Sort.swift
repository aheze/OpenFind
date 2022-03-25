//
//  PhotosVM+Sort.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewModel {
    func sort() {
        var allSections = [PhotosSection]()
        var starredSections = [PhotosSection]()
        var screenshotsSections = [PhotosSection]()

        for photo in photos {
            guard let dateCreatedCategorization = photo.asset.getDateCreatedCategorization() else { continue }
            let existingSectionIndex = allSections.firstIndex { $0.categorization == dateCreatedCategorization }

            if let existingSectionIndex = existingSectionIndex {
                allSections[existingSectionIndex].photos.append(photo)
            } else {
                let newSection = PhotosSection(title: dateCreatedCategorization.getTitle(), categorization: dateCreatedCategorization, photos: [photo])
                allSections.append(newSection)
            }

            if photo.isStarred() {
                let existingSectionIndex = starredSections.firstIndex { $0.categorization == dateCreatedCategorization }
                if let existingSectionIndex = existingSectionIndex {
                    starredSections[existingSectionIndex].photos.append(photo)
                } else {
                    let newSection = PhotosSection(title: dateCreatedCategorization.getTitle(), categorization: dateCreatedCategorization, photos: [photo])
                    starredSections.append(newSection)
                }
            }

            if photo.isScreenshot() {
                let existingSectionIndex = screenshotsSections.firstIndex { $0.categorization == dateCreatedCategorization }
                if let existingSectionIndex = existingSectionIndex {
                    screenshotsSections[existingSectionIndex].photos.append(photo)
                } else {
                    let newSection = PhotosSection(title: dateCreatedCategorization.getTitle(), categorization: dateCreatedCategorization, photos: [photo])
                    screenshotsSections.append(newSection)
                }
            }
        }

        self.allSections = allSections
        self.starredSections = starredSections
        self.screenshotsSections = screenshotsSections
    }
}
