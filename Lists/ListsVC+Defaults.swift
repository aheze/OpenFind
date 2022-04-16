//
//  ListsVC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func listenToDefaults() {
        self.listen(
            to: RealmModelData.listsSortBy.key,
            selector: #selector(self.listsSortByChanged)
        )
    }

    @objc func listsSortByChanged() {
        if model.loaded {
            reload()
        }
    }
}
