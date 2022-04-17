//
//  TabBarVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension TabBarViewController {
    func makeFlowLayout() -> ContentPagingFlowLayout {
        let flowLayout = ContentPagingFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getTabs = { [weak self] in
            guard let self = self else { return [] }
            return self.pages.map { $0.tabType }
        }
            
        /// get initial offset
        flowLayout.getInitialContentOffset = { [weak self] in
            guard let self = self else { return nil }
            switch self.realmModel.defaultTab {
            case .photos:
                return 0
            case .camera:
                return self.contentCollectionView.bounds.width
            case .lists:
                return self.contentCollectionView.bounds.width * 2
            }
        }
            
        contentCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
}
