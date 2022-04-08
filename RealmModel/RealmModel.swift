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

    // MARK: Finding
    @Saved("findingPrimaryRecognitionLanguage") var findingPrimaryRecognitionLanguage = Settings.Values.RecognitionLanguage.english.rawValue
    @Saved("findingSecondaryRecognitionLanguage") var findingSecondaryRecognitionLanguage = Settings.Values.RecognitionLanguage.none.rawValue
    
    @Saved("findingKeepWhitespace") var findingKeepWhitespace = false
    @Saved("findingMatchAccents") var findingMatchAccents = false
    @Saved("findingMatchCase") var findingMatchCase = false
    @Saved("findingFilterLists") var findingFilterLists = true

    // MARK: Highlights

    @Saved("highlightsColor") var highlightsColor = Int(0x00aeef)
    @Saved("highlightsCycleSearchBarColors") var highlightsCycleSearchBarColors = true
    @Saved("highlightsBorderWidth") var highlightsBorderWidth = Double(1.2)
    @Saved("highlightsBackgroundOpacity") var highlightsBackgroundOpacity = Double(0.3)

    // MARK: Photos

    @Saved("photosScanOnLaunch") var photosScanOnLaunch = false
    @Saved("photosScanOnAddition") var photosScanOnAddition = true
    @Saved("photosScanOnFind") var photosScanOnFind = true
    @Saved("photosMinimumCellLength") var photosMinimumCellLength = CGFloat(80)
    
    // MARK: Camera
    
    @Saved("cameraHapticFeedbackLevel") var cameraHapticFeedbackLevel = Settings.Values.HapticFeedbackLevel.light
    @Saved("cameraScanningFrequency") var cameraScanningFrequency = Settings.Values.ScanningFrequencyLevel.halfSecond.rawValue
    @Saved("cameraScanningDurationUntilPause") var cameraScanningDurationUntilPause = Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.rawValue

    // MARK: Lists
    @Saved("listsSortBy") var listsSortBy = Settings.Values.ListsSortByLevel.newestFirst.rawValue
    

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

        _findingPrimaryRecognitionLanguage.configureValueChanged(with: self)
        _findingSecondaryRecognitionLanguage.configureValueChanged(with: self)
        _findingKeepWhitespace.configureValueChanged(with: self)
        _findingMatchAccents.configureValueChanged(with: self)
        _findingMatchCase.configureValueChanged(with: self)
        _findingFilterLists.configureValueChanged(with: self)

        _highlightsColor.configureValueChanged(with: self)
        _highlightsCycleSearchBarColors.configureValueChanged(with: self)
        _highlightsBorderWidth.configureValueChanged(with: self)
        _highlightsBackgroundOpacity.configureValueChanged(with: self)

        _photosScanOnLaunch.configureValueChanged(with: self)
        _photosScanOnAddition.configureValueChanged(with: self)
        _photosScanOnFind.configureValueChanged(with: self)
        _photosMinimumCellLength.configureValueChanged(with: self)
        
        _cameraHapticFeedbackLevel.configureValueChanged(with: self)
        _cameraScanningFrequency.configureValueChanged(with: self)
        _cameraScanningDurationUntilPause.configureValueChanged(with: self)
        
        _listsSortBy.configureValueChanged(with: self)
    }
}



