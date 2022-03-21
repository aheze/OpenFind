//
//  IgnoredPhotosVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController {
    func makeFlowLayout() -> PhotosCollectionFlowLayout {
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
