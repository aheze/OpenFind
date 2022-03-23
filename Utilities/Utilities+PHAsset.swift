//
//  Utilities+PHAsset.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PHAsset {
    func getDateCreatedCategorization() -> PhotosSection.Categorization? {
        if
            let components = creationDate?.get(.year, .month),
            let year = components.year, let month = components.month
        {
            let categorization = PhotosSection.Categorization.date(year: year, month: month)
            return categorization
        }
        return nil
    }
}

extension PHAsset {
    var originalFilename: String? {
        var fileName: String?

        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fileName = resource.originalFilename
            }
        }

        if fileName == nil {
            /// This is an undocumented workaround that works as of iOS 9.1
            fileName = self.value(forKey: "filename") as? String
        }

        return fileName
    }
}
