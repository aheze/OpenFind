//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

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
