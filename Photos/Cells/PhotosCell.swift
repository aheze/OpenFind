//
//  PhotosCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

class PhotosCell: UICollectionViewCell {
    /// when fetching an image, this will be populated
    var fetchingID: PHImageRequestID?

    var representedAssetIdentifier: String?
    var model = PhotosCellImageViewModel()
    var view: UIView?
}
