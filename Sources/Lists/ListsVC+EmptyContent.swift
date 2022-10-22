//
//  ListsVC+EmptyContent.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension ListsViewController {
    func setupEmptyContent() {
        let viewController = UIHostingController(
            rootView: ListsEmptyContentView(
                model: model,
                realmModel: realmModel
            )
        )
        viewController.view.backgroundColor = .clear
        contentContainer.backgroundColor = .clear
        contentContainer.alpha = 0
        addChildViewController(viewController, in: contentContainer)
    }

    func showEmptyContent(_ show: Bool) {
        if show {
            UIView.animate(withDuration: 0.3) {
                self.contentContainer.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.contentContainer.alpha = 0
            }
        }
    }
}
