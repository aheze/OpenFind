//
//  SettingsViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI
import SwiftPrettyPrint

/// for the view
enum SettingsIdentifiers {
    static var hapticFeedbackLevel = "hapticFeedbackLevel"
}

class SettingsViewModel: ObservableObject {
    @Saved("swipeToNavigate") var swipeToNavigate = true
    @Saved("hapticFeedbackLevel") var hapticFeedbackLevel = "low"
    @Saved("scanOnLaunch") var scanOnLaunch = false
    @Saved("scanOnFind") var scanOnFind = true
    
    var page = mainPage
    var paths: [[SettingsRow]] /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    /// update navigation bar height from within a page view controller
    var updateNavigationBar: (() -> Void)?
    
    /// show a page
    var show: ((SettingsPage) -> Void)?
    
    init() {
        let paths = page.generatePaths()
        self.paths = paths
        
        print("swipe? \(swipeToNavigate)")
        
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value)")
        }
    }
}


