//
//  SettingsController+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension SettingsController {
    func listen() {
        model.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchController.updateSearchBarOffset()
        }
        model.show = { [weak self] page in
            guard let self = self else { return }
            let scrollViewController = SettingsScrollViewController(
                model: self.model,
                searchViewModel: self.searchViewModel,
                page: page
            )
            self.searchController.navigation.pushViewController(scrollViewController, animated: true)
        }
    }
}
