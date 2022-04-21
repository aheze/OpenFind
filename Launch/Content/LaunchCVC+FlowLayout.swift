//
//  LaunchCVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension LaunchContentViewController {
    func makeFlowLayout() -> LaunchContentFlowLayout {
        let flowLayout = LaunchContentFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getPages = { [weak self] in
            guard let self = self else { return [] }
            return self.model.pages
        }

        flowLayout.currentIndexChanged = { [weak self] in
            guard let self = self else { return }

            if let page = self.model.pages[safe: self.flowLayout.currentIndex] {
                self.model.setCurrentPage(to: page)
            }
        }

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
}
