//
//  RealmModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class RealmModel: ObservableObject {
    var container = RealmContainer()

    @Published var lists = [List]()
    @Published var photoMetadatas = [PhotoMetadata]()

    // MARK: - Defaults

    @Saved("swipeToNavigate") var swipeToNavigate = true
    @Saved("hapticFeedbackLevel") var hapticFeedbackLevel = Settings.Values.HapticFeedbackLevel.light

    // MARK: Finding

    @Saved("keepWhitespace") var keepWhitespace = false
    @Saved("matchAccents") var matchAccents = false
    @Saved("matchCase") var matchCase = false
    @Saved("filterLists") var filterLists = true

    // MARK: Highlights

    @Saved("highlightsColor") var highlightsColor = Int(0x00aeef)
    @Saved("cycleSearchBarColors") var cycleSearchBarColors = true
    @Saved("highlightsBorderWidth") var highlightsBorderWidth = Double(1.2)
    @Saved("highlightsBackgroundOpacity") var highlightsBackgroundOpacity = Double(0.3)

    // MARK: Photos

    @Saved("scanOnLaunch") var scanOnLaunch = false
    @Saved("scanOnFind") var scanOnFind = true
    @Saved("minimumCellLength") var minimumCellLength = CGFloat(80)
    
    // MARK: Camera
    @Saved("pauseScanningAfter") var pauseScanningAfter = Settings.Values.PauseScanningAfterLevel.thirtySeconds.rawValue

    init() {
        container.listsUpdated = { [weak self] lists in
            self?.lists = lists
        }
        container.photoMetadatasUpdated = { [weak self] photoMetadatas in
            self?.photoMetadatas = photoMetadatas
        }

        container.loadLists()
        container.loadPhotoMetadatas()

        listenToDefaults()
    }

    func listenToDefaults() {
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
        _minimumCellLength.configureValueChanged(with: self)
        
        _pauseScanningAfter.configureValueChanged(with: self)
    }
}
