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
        flowLayout.getContent = { [weak self] in
            guard let self = self else { return .photos([]) }
            let type = PhotosCollectionType.photos(self.model.ignoredPhotos)
            return type
        }

        return flowLayout
    }
}
