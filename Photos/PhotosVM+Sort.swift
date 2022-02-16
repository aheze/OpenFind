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
        var sections = [PhotosSection]()
        for photo in photos {
            if let dateCreatedCategorization = photo.asset.getDateCreatedCategorization() {
                let existingSectionIndex = sections.firstIndex { $0.categorization == dateCreatedCategorization }
                if let existingSectionIndex = existingSectionIndex {
                    sections[existingSectionIndex].photos.append(photo)
                } else {
                    let newSection = PhotosSection(title: dateCreatedCategorization.getTitle(), categorization: dateCreatedCategorization, photos: [photo])
                    sections.append(newSection)
                }
            }
        }
        self.sections = sections
    }

    func checkIfPhotoHas(same component: DateComponents) {}
}
