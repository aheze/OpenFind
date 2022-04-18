//
//  VC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ViewController {
    func listenToDefaults() {
        self.listen(
            to: RealmModelData.listsSortBy.key,
            selector: #selector(self.listsSortByChanged)
        )
    }

    @objc func listsSortByChanged() {
        realmModel.loadAndSortLists(realmModel.lists)
    }
}
