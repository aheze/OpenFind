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
        flowLayout.getPages = {
            LaunchPage.allCases
        }

        flowLayout.currentIndexChanged = { [weak self] in
            guard let self = self else { return }

            withAnimation {
                if let page = LaunchPage(rawValue: self.flowLayout.currentIndex) {
                    self.model.currentPage = page
                }
            }
        }

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
}
