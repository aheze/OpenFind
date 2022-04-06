//
//  PhotosSpecifiedExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotoMetadata {
    static func apply(metadata: PhotoMetadata?, to cell: PhotosCollectionCell) {
        if let metadata = metadata, metadata.isStarred {
            cell.view.overlayGradientImageView.alpha = 1
            cell.view.overlayStarImageView.alpha = 1
            return
        }

        cell.view.overlayGradientImageView.alpha = 0
        cell.view.overlayStarImageView.alpha = 0
    }
}
