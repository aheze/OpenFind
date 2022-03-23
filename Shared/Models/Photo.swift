//
//  Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct Photo: Hashable {
    var asset: PHAsset
    var metadata: PhotoMetadata?

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.asset)
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }
}

struct PhotoMetadata {
    var assetIdentifier = ""
    var sentences = [Sentence]()
    var dateScanned: Date?
    var isStarred = false
    var isIgnored = false
}

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
