//
//  LaunchVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import UIKit

extension LaunchViewController {
    func listen() {
        model.$currentPage
            .dropFirst()
            .sink { [weak self] page in
                guard let self = self else { return }

                UIView.animate(withDuration: 0.3) {
                    if page == .empty {
                        self.sceneContainer.alpha = 1
                    } else {
                        self.sceneContainer.alpha = 0
                    }
                }
            }
            .store(in: &model.cancellables)
    }
}
