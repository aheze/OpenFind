//
//  Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit
import Photos

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
    var isScanned = false
    var isStarred = false
}
