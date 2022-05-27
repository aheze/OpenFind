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

enum TipIdentifier: String {
    case photosGallerySearch
}

enum RealmModelData {
    // MARK: Storage

    static var experiencePoints = SavedData(key: "experiencePoints", value: 0)
    
    // MARK: General
    
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
    
    static var highlightsColor = SavedData(key: "highlightsColor", value: Int(0x009AEF))
    static var highlightsCycleSearchBarColors = SavedData(key: "highlightsCycleSearchBarColors", value: true)
    static var highlightsBorderWidth = SavedData(key: "highlightsBorderWidth", value: Double(1.2))
    static var highlightsBackgroundOpacity = SavedData(key: "highlightsBackgroundOpacity", value: Double(0.3))
    static var highlightsPaddingPercentage = SavedData(key: "highlightsPaddingPercentage", value: Double(0.1))
    
    // MARK: Photos

    static var photosScanOnLaunch = SavedData(key: "photosScanOnLaunch", value: false)
    static var photosScanOnAddition = SavedData(key: "photosScanOnAddition", value: true)
    static var photosScanOnFind = SavedData(key: "photosScanOnFind", value: true)
    static var photosMinimumCellLength = SavedData(key: "photosMinimumCellLength", value: CGFloat(80))
    static var photosResultsCellLayout = SavedData(key: "photosResultsCellLayout", value: Settings.Values.PhotosResultsCellLayout.medium.rawValue)
    static var photosResultsInsertNewMode = SavedData(key: "photosResultsInsertNewMode", value: Settings.Values.PhotosResultsInsertNewMode.top.rawValue)
    static var photosRenderResultsHighlights = SavedData(key: "photosRenderResultsHighlights", value: true) /// load highlights in results
    
    // MARK: Camera
    
    static var cameraHapticFeedbackLevel = SavedData(key: "cameraHapticFeedbackLevel", value: Settings.Values.HapticFeedbackLevel.light.rawValue)
    static var cameraScanningFrequency = SavedData(key: "cameraScanningFrequency", value: Settings.Values.ScanningFrequencyLevel.tenthSecond.rawValue)
    static var cameraScanningDurationUntilPause = SavedData(key: "cameraScanningDurationUntilPause", value: Settings.Values.ScanningDurationUntilPauseLevel.thirtySeconds.rawValue)
    static var cameraStabilizationMode = SavedData(key: "cameraStabilizationMode", value: Settings.Values.StabilizationMode.off.rawValue)
    
    
    
    // MARK: Lists

    static var listsSortBy = SavedData(key: "listsSortBy", value: Settings.Values.ListsSortByLevel.newestFirst.rawValue)
}
