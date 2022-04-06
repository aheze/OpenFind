//
//  SettingsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftPrettyPrint
import SwiftUI

class SettingsViewModel: ObservableObject {
    var page = SettingsData.mainPage
    var paths: [[SettingsRow]] /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    /// width of page
    var pageWidth = CGFloat(0)
    
    /// update navigation bar height from within a page view controller
    var updateNavigationBar: (() -> Void)?

    /// show a page
    var show: ((SettingsPage) -> Void)?

    /// callback from the settings page. Listen inside `SettingsVC+Listen`
    var showHighlightColorPicker: (() -> Void)?
    

    init() {
        let paths = self.page.generatePaths()
        self.paths = paths
    }
}
