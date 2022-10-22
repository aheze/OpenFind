//
//  IgnoredPhotosVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension IgnoredPhotosViewController {
    func listen() {
        /// results top header
        headerContentModel.sizeChanged = { [weak self] in
            guard let self = self else { return }
            self.ignoredPhotosHeaderHeightC?.constant = self.headerContentModel.size?.height ?? 0
            self.flowLayout.invalidateLayout()
        }
    }
}
