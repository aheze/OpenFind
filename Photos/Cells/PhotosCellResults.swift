//
//  PhotosCellResultsImageViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

class PhotosCellResults: UICollectionViewCell {
    /// when fetching an image, this will be populated
    var fetchingID: PHImageRequestID?
    var representedAssetIdentifier: String?
    var containerView: UIView?

    var model = PhotosCellImageViewModel()
    var resultsModel = PhotosCellResultsImageViewModel()
    var textModel = EditableTextViewModel(configuration: .cellResults)
    var highlightsViewModel: HighlightsViewModel = {
        let model = HighlightsViewModel()
        model.shouldScaleHighlights = false
        return model
    }()

    var realmModel: RealmModel?
}
