//
//  SettingsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import SwiftPrettyPrint

class SettingsViewModel: ObservableObject {
    @Saved("swipeToNavigate") var swipeToNavigate = true
    @Saved("hapticFeedbackLevel") var hapticFeedbackLevel = "low"
    @Saved("scanOnLaunch") var scanOnLaunch = false
    @Saved("scanOnFind") var scanOnFind = true
    
    var page = mainPage
    var paths: [[SettingsRow]]? /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    init() {
        let paths = page.generatePaths()
//        Pretty.prettyPrint(paths)
        self.paths = paths
    }
}


