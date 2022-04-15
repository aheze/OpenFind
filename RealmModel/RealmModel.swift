//
//  RealmModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

class RealmModel: ObservableObject {
    var container = RealmContainer()

    @Published private(set) var lists = [List]()

    @Published private(set) var photoMetadatas = [PhotoMetadata]()

    static let data = RealmModelData.self

    var cancellables = Set<AnyCancellable>()

    // MARK: - Defaults

    @Saved(data.defaultTab.key) var defaultTab = data.defaultTab.value
    @Saved(data.swipeToNavigate.key) var swipeToNavigate = data.swipeToNavigate.value

    // MARK: Finding

    @Saved(data.findingPrimaryRecognitionLanguage.key) var findingPrimaryRecognitionLanguage = data.findingPrimaryRecognitionLanguage.value
    @Saved(data.findingSecondaryRecognitionLanguage.key) var findingSecondaryRecognitionLanguage = data.findingSecondaryRecognitionLanguage.value

    @Saved(data.findingKeepWhitespace.key) var findingKeepWhitespace = data.findingKeepWhitespace.value
    @Saved(data.findingMatchAccents.key) var findingMatchAccents = data.findingMatchAccents.value
    @Saved(data.findingMatchCase.key) var findingMatchCase = data.findingMatchCase.value
    @Saved(data.findingFilterLists.key) var findingFilterLists = data.findingFilterLists.value

    // MARK: Highlights

    @Saved(data.highlightsColor.key) var highlightsColor = data.highlightsColor.value
    @Saved(data.highlightsCycleSearchBarColors.key) var highlightsCycleSearchBarColors = data.highlightsCycleSearchBarColors.value
    @Saved(data.highlightsBorderWidth.key) var highlightsBorderWidth = data.highlightsBorderWidth.value
    @Saved(data.highlightsBackgroundOpacity.key) var highlightsBackgroundOpacity = data.highlightsBackgroundOpacity.value

    // MARK: Photos

    @Saved(data.photosScanOnLaunch.key) var photosScanOnLaunch = data.photosScanOnLaunch.value
    @Saved(data.photosScanOnAddition.key) var photosScanOnAddition = data.photosScanOnAddition.value
    @Saved(data.photosScanOnFind.key) var photosScanOnFind = data.photosScanOnFind.value
    @Saved(data.photosMinimumCellLength.key) var photosMinimumCellLength = data.photosMinimumCellLength.value

    // MARK: Camera

    @Saved(data.cameraHapticFeedbackLevel.key) var cameraHapticFeedbackLevel = data.cameraHapticFeedbackLevel.value
    @Saved(data.cameraScanningFrequency.key) var cameraScanningFrequency = data.cameraScanningFrequency.value
    @Saved(data.cameraScanningDurationUntilPause.key) var cameraScanningDurationUntilPause = data.cameraScanningDurationUntilPause.value

    // MARK: Lists

    @Saved(data.listsSortBy.key) var listsSortBy = data.listsSortBy.value

    init() {
        container.listsUpdated = { [weak self] lists in
            self?.lists = lists
        }

        container.photoMetadatasUpdated = { [weak self] photoMetadatas in
            self?.photoMetadatas = photoMetadatas
        }

        container.loadLists()

        listenToDefaults()
    }

    func listenToDefaults() {
        _defaultTab.configureValueChanged(with: self)
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

    /// get the photo metadata of an photo if it exists
    func getPhotoMetadata(from identifier: String) -> PhotoMetadata? {
        if let photoMetadata = photoMetadatas.first(where: { $0.assetIdentifier == identifier }) {
            return photoMetadata
        }
        return nil
    }
}

extension RealmModel {
    func resetAllSettings() {
        let data = RealmModelData.self

        swipeToNavigate = data.swipeToNavigate.value
        findingPrimaryRecognitionLanguage = data.findingPrimaryRecognitionLanguage.value
        findingSecondaryRecognitionLanguage = data.findingSecondaryRecognitionLanguage.value
        findingKeepWhitespace = data.findingKeepWhitespace.value
        findingMatchAccents = data.findingMatchAccents.value
        findingMatchCase = data.findingMatchCase.value
        findingFilterLists = data.findingFilterLists.value
        highlightsColor = data.highlightsColor.value
        highlightsCycleSearchBarColors = data.highlightsCycleSearchBarColors.value
        highlightsBorderWidth = data.highlightsBorderWidth.value
        highlightsBackgroundOpacity = data.highlightsBackgroundOpacity.value
        photosScanOnLaunch = data.photosScanOnLaunch.value
        photosScanOnAddition = data.photosScanOnAddition.value
        photosScanOnFind = data.photosScanOnFind.value
        photosMinimumCellLength = data.photosMinimumCellLength.value
        cameraHapticFeedbackLevel = data.cameraHapticFeedbackLevel.value
        cameraScanningFrequency = data.cameraScanningFrequency.value
        cameraScanningDurationUntilPause = data.cameraScanningDurationUntilPause.value
    }
}

extension Saved {
    /// listen to value changed
    mutating func configureValueChanged(with model: RealmModel) {
        let key = self.key
        valueChanged = { [weak model] in
            model?.objectWillChange.send()
            NotificationCenter.default.post(name: Notification.Name(key), object: nil)
        }
    }
}

extension NSObject {
    /// listen to a Realm Defaults notification, calling the selector at first too
    func listen(to key: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(key), object: nil)
        perform(selector)
    }
}
