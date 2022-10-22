//
//  PhotosVC+Sorting.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Photos
import SwiftUI
import UIKit

struct Month: Hashable {
    var id = UUID()
    var monthDate: Date
    var photos: [FindPhoto]
    
    init(monthDate: Date, photos: [FindPhoto]) {
        self.monthDate = monthDate
        self.photos = photos
        id = UUID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}

class MutableMonth {
    var id = UUID()
    var monthDate = Date()
    var photos = [FindPhoto]()
}

class FindPhoto: Hashable {
    var id = UUID()
    var asset = PHAsset()
    var editableModel: EditableHistoryModel?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FindPhoto, rhs: FindPhoto) -> Bool {
        return lhs.id == rhs.id && lhs.editableModel == rhs.editableModel
    }
}

extension PhotosViewController {
    func getSliderCallback() {
        segmentedSlider.pressedFilter = { [weak self] filterState in
            guard let self = self else { return }
            
            self.photoFilterState = filterState
            self.sortPhotos(with: filterState)
            self.applySnapshot(animatingDifferences: true)
        }
    }

    func sortPhotos(with filterState: PhotoFilterState) {
        var allPhotosToDisplay = [FindPhoto]()
        
        func determineIncludedInStarAndCache(_ state: PhotoFilterState, model: EditableHistoryModel?) -> Bool {
            if state.starSelected {
                if state.cacheSelected {
                    let photoStarred = model?.isHearted ?? false
                    let photoCached = model?.isDeepSearched ?? false
                    return photoStarred && photoCached
                } else {
                    let photoStarred = model?.isHearted ?? false
                    return photoStarred
                }
            } else {
                if state.cacheSelected {
                    let photoCached = model?.isDeepSearched ?? false
                    return photoCached
                } else {
                    return true
                }
            }
        }
        
        switch filterState.currentFilter {
        case .local:
            var filteredMonths = allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    let photoTakenLocally = photo.editableModel?.isTakenLocally ?? false

                    return photoTakenLocally && determineIncludedInStarAndCache(filterState, model: photo.editableModel)
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                !month.photos.isEmpty
            }
            monthsToDisplay = filteredMonths
        case .screenshots:
            var filteredMonths = allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    
                    let asset = photo.asset
                    let types = asset.mediaSubtypes
                    let isScreenshot = types.contains(.photoScreenshot)

                    return isScreenshot && determineIncludedInStarAndCache(filterState, model: photo.editableModel)
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                !month.photos.isEmpty
            }
            monthsToDisplay = filteredMonths
        case .all:
            var filteredMonths = allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    determineIncludedInStarAndCache(filterState, model: photo.editableModel)
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                !month.photos.isEmpty
            }
            monthsToDisplay = filteredMonths
            
            if TipViews.currentStarStep == 1 {
                startStarSecondStep()
            }
            if TipViews.currentCacheStep == 1 {
                startCacheSecondStep()
            }
        }
        
        if TipViews.inTutorial {
            /// star is already deselected, cache left
            if !filterState.starSelected {
                if filterState.cacheSelected {
                    if TipViews.currentStarStep == 0, TipViews.currentCacheStep == 0 {
                        removeFilters(type: .cached)
                    }
                } else {
                    if TipViews.queuingStar {
                        if filterState.currentFilter == .all {
                            startStarSecondStep()
                        } else {
                            startTutorial?(.starred)
                        }
                    } else if TipViews.queuingCache {
                        if filterState.currentFilter == .all {
                            startCacheSecondStep()
                        } else {
                            startTutorial?(.cached)
                        }
                    }
                }
            }
        }
        
        self.allPhotosToDisplay = allPhotosToDisplay
        
        if allPhotosToDisplay.isEmpty {
            var types = [PhotoTutorialType]()
            if filterState.starSelected { types.append(.starred) }
            if filterState.cacheSelected { types.append(.cached) }
            switch filterState.currentFilter {
            case .local:
                types.append(.local)
            case .screenshots:
                types.append(.screenshots)
            case .all:
                types.append(.all)
            }
            
            showEmptyView(for: types)
            findButton.isEnabled = false
            selectButton.isEnabled = false
        } else {
            hideEmptyView()
            findButton.isEnabled = true
            selectButton.isEnabled = true
        }
        
        updateFindButtonHint()
    }
}
