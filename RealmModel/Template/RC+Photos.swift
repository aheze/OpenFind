//
//  RC+Photos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmContainer {
    func loadPhotoMetadatas() {}

    func deleteAllMetadata() {}

    func updatePhotoMetadata(metadata: PhotoMetadata?) {}

    func deletePhotoMetadata(metadata: PhotoMetadata) {}

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {}
}
