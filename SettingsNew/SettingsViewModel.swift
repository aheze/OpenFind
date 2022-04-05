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
    @Saved("swipeToNavigate") var swipeToNavigate = true
    @Saved("hapticFeedbackLevel") var hapticFeedbackLevel = Settings.Values.HapticFeedbackLevel.light

    // MARK: - Finding

    @Saved("keepWhitespace") var keepWhitespace = false
    @Saved("matchAccents") var matchAccents = false
    @Saved("matchCase") var matchCase = false
    @Saved("filterLists") var filterLists = true
    @Saved("scanOnLaunch") var scanOnLaunch = false
    @Saved("scanOnFind") var scanOnFind = true

    // MARK: - Highlights

    @Saved("highlightsColor") var highlightsColor = Int(0x00aeef)
    @Saved("cycleSearchBarColors") var cycleSearchBarColors = true
    @Saved("highlightsBorderWidth") var highlightsBorderWidth = Double(1.2)
    @Saved("highlightsBackgroundOpacity") var highlightsBackgroundOpacity = Double(0.3)

    var page = mainPage
    var paths: [[SettingsRow]] /// all possible paths in the tree, including incomplete/unfinished paths (paths that stop before hitting the last option)

    /// update navigation bar height from within a page view controller
    var updateNavigationBar: (() -> Void)?

    /// show a page
    var show: ((SettingsPage) -> Void)?

    var showHighlightColorPicker: (() -> Void)?

    init() {
        let paths = self.page.generatePaths()
        self.paths = paths

        _highlightsBorderWidth.configureValueChanged(with: self)
    }
}

extension Saved {
    mutating func configureValueChanged(with model: SettingsViewModel) {
        self.valueChanged = { [weak model] in
            model?.objectWillChange.send()
        }
    }

//    func configureValueChanged<Value>(for variable: inout Saved<Value>) {
//        variable.valueChanged = { [weak self] in
//            self?.objectWillChange.send()
//        }
//    }
}
