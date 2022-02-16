//
//  PhotosViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

class PhotosViewModel {
    var realmModel: RealmModel?
    var assets: PHFetchResult<PHAsset>?
    var photos = [Photo]()
    var sections = [PhotosSection]()

    var reload: (() -> Void)?

    /// PHAsset caching
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero
}

extension PHAsset {
    func getDateCreatedCategorization() -> PhotosSection.Categorization? {
        if
            let components = creationDate?.get(.year, .month, .day),
            let year = components.year, let month = components.month, let day = components.day
        {
            let categorization = PhotosSection.Categorization.date(year: year, month: month, day: day)
            return categorization
        }
        return nil
    }
}
