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

                self.updateUI(for: page)
            }
            .store(in: &model.cancellables)
    }

    func updateUI(for page: LaunchPageIdentifier) {
        UIView.animate(withDuration: 0.3) {
            if page == .empty || page == .final {
                self.sceneContainer.alpha = 1
            } else {
                self.sceneContainer.alpha = 0
            }
        }

        UIView.animate(duration: 1.9, dampingFraction: 0.6) {
            if page == .final {
                self.sceneContainer.transform = .init(scaleX: 1.4, y: 1.4)
            } else {
                self.sceneContainer.transform = .identity
            }
        }
    }
}
