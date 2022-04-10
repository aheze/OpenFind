//
//  SettingsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    var page = SettingsData.mainPage
    var paths: [[SettingsRow]] /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    @Published var resultsSections = [SettingsSection]()

    /// width of page
    var pageWidth = CGFloat(0)

    /// update navigation bar height from within a page view controller
    var updateNavigationBar: (() -> Void)?

    /// show a page
    var show: ((SettingsPage) -> Void)?

    /// deep linking
    var showRows: (([SettingsRow]) -> Void)?

    /// callback from the settings page. Listen inside `SettingsVC+Listen`
    var showHighlightColorPicker: (() -> Void)?
    
    /// resume the camera
    var startedToDismiss: (() -> Void)?
    
    @Published var touchesEnabled = true

    init() {
        let paths = self.page.generatePaths()
        self.paths = paths
    }
}
