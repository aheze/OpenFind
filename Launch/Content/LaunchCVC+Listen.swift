//
//  LaunchCVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension LaunchContentViewController {
    func listen() {
        model.$currentPage
            .dropFirst()
            .sink { [weak self] page in
                guard let self = self else { return }
                self.collectionView.scrollToItem(at: page.rawValue.indexPath, at: .centeredHorizontally, animated: true)
            }
            .store(in: &model.cancellables)
    }
}
