//
//  IgnoredPhotosVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController {
    func setup() {
        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()

        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.collectionViewLayout = flowLayout
    }

    func createFlowLayout() -> PhotosCollectionFlowLayout {
        let flowLayout = PhotosCollectionFlowLayout()
        flowLayout.getSections = { [weak self] in
            guard let self = self else { return [] }

            let section = Section(
                items: Array(
                    repeating: Section.Item.placeholder,
                    count: self.model.ignoredPhotos.count
                )
            )

            return [section]
        }

        return flowLayout
    }
}
