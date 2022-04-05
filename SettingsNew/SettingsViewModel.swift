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
    @Saved("swipeToNavigate") var swipeToNavigate = true { willSet { self.objectWillChange.send() } }
    @Saved("hapticFeedbackLevel") var hapticFeedbackLevel = Settings.Values.HapticFeedbackLevel.light { willSet { self.objectWillChange.send() } }

    // MARK: - Finding

    @Saved("keepWhitespace") var keepWhitespace = false { willSet { self.objectWillChange.send() } }
    @Saved("matchAccents") var matchAccents = false { willSet { self.objectWillChange.send() } }
    @Saved("matchCase") var matchCase = false { willSet { self.objectWillChange.send() } }
    @Saved("filterLists") var filterLists = true { willSet { self.objectWillChange.send() } }

    @Saved("scanOnLaunch") var scanOnLaunch = false { willSet { self.objectWillChange.send() } }
    @Saved("scanOnFind") var scanOnFind = true { willSet { self.objectWillChange.send() } }
    
    // MARK: - Highlights
    @Saved("highlightsColor") var highlightsColor = Int(0x00aeef) { willSet { self.objectWillChange.send() } }
    @Saved("cycleSearchBarColors") var cycleSearchBarColors = true { willSet { self.objectWillChange.send() } }
    @Saved("highlightsBorderWidth") var highlightsBorderWidth = Double(1.2) { willSet { self.objectWillChange.send() } }
    @Saved("highlightsBackgroundOpacity") var highlightsBackgroundOpacity = Double(0.3) { willSet { self.objectWillChange.send() } }
    
    var page = mainPage
    var paths: [[SettingsRow]] /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    /// update navigation bar height from within a page view controller
    var updateNavigationBar: (() -> Void)?

    /// show a page
    var show: ((SettingsPage) -> Void)?

    init() {
        let paths = page.generatePaths()
        self.paths = paths
    }
}
