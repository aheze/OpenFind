//
//  RealmModelData.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

struct SavedData<Value> {
    var key: String
    var value: Value
}

enum RealmModelData {
    static var defaultTab = SavedData(key: "defaultTab", value: Settings.Values.Tab.camera)
    static var swipeToNavigate = SavedData(key: "swipeToNavigate", value: true)
    
    // MARK: Finding

    /// for both Photos and Camera
    static var findingPrimaryRecognitionLanguage = SavedData(key: "findingPrimaryRecognitionLanguage", value: Settings.Values.RecognitionLanguage.english.rawValue)
    static var findingSecondaryRecognitionLanguage = SavedData(key: "findingSecondaryRecognitionLanguage", value: Settings.Values.RecognitionLanguage.none.rawValue)
    
    static var findingKeepWhitespace = SavedData(key: "findingKeepWhitespace", value: false)
    static var findingMatchAccents = SavedData(key: "findingMatchAccents", value: false)
    static var findingMatchCase = SavedData(key: "findingMatchCase", value: false)
    static var findingFilterLists = SavedData(key: "findingFilterLists", value: true)
    
    // MARK: Highlights
    
    static var highlightsColor = SavedData(key: "highlightsColor", value: Int(0x00aeef))
    static var highlightsCycleSearchBarColors = SavedData(key: "highlightsCycleSearchBarColors", value: true)
    static var highlightsBorderWidth = SavedData(key: "highlightsBorderWidth", value: Double(1.2))
    static var highlightsBackgroundOpacity = SavedData(key: "highlightsBackgroundOpacity", value: Double(0.3))
    
    // MARK: Photos

    static var photosScanOnLaunch = SavedData(key: "photosScanOnLaunch", value: false)
    static var photosScanOnAddition = SavedData(key: "photosScanOnAddition", value: true)
    static var photosScanOnFind = SavedData(key: "photosScanOnFind", value: true)
    static var photosMinimumCellLength = SavedData(key: "photosMinimumCellLength", value: CGFloat(80))

    // MARK: Camera
    
    static var cameraHapticFeedbackLevel = SavedData(key: "cameraHapticFeedbackLevel", value: Settings.Values.HapticFeedbackLevel.light)
    static var cameraScanningFrequency = SavedData(key: "cameraScanningFrequency", value: Settings.Values.ScanningFrequencyLevel.tenthSecond.rawValue)
    static var cameraScanningDurationUntilPause = SavedData(key: "cameraScanningDurationUntilPause", value: Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.rawValue)
    
    // MARK: Lists

    static var listsSortBy = SavedData(key: "listsSortBy", value: Settings.Values.ListsSortByLevel.newestFirst.rawValue)
}
