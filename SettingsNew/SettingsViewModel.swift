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

    // MARK: - Highlights

    @Saved("highlightsColor") var highlightsColor = Int(0x00aeef)
    @Saved("cycleSearchBarColors") var cycleSearchBarColors = true
    @Saved("highlightsBorderWidth") var highlightsBorderWidth = Double(1.2)
    @Saved("highlightsBackgroundOpacity") var highlightsBackgroundOpacity = Double(0.3)

    // MARK: - Photos
    @Saved("scanOnLaunch") var scanOnLaunch = false
    @Saved("scanOnFind") var scanOnFind = true

    
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

        _swipeToNavigate.configureValueChanged(with: self)
        _hapticFeedbackLevel.configureValueChanged(with: self)
        
        _keepWhitespace.configureValueChanged(with: self)
        _matchCase.configureValueChanged(with: self)
        _filterLists.configureValueChanged(with: self)

        _highlightsColor.configureValueChanged(with: self)
        _cycleSearchBarColors.configureValueChanged(with: self)
        _highlightsBorderWidth.configureValueChanged(with: self)
        _highlightsBackgroundOpacity.configureValueChanged(with: self)
        
        _scanOnLaunch.configureValueChanged(with: self)
        _scanOnFind.configureValueChanged(with: self)
    }
}

extension Saved {
    
    /// listen to value changed
    mutating func configureValueChanged(with model: SettingsViewModel) {
        self.valueChanged = { [weak model] in
            model?.objectWillChange.send()
        }
    }
}
