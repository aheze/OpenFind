//
//  PhotosVC+Sorting.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import SwiftUI

struct Month: Hashable {
    var id = UUID()
    var monthDate: Date
    var photos: [FindPhoto]
    
    init(monthDate: Date, photos: [FindPhoto]) {
        self.monthDate = monthDate
        self.photos = photos
        self.id = UUID()
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
            
            self.sortPhotos(with: filterState)
            self.photoFilterState = filterState
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
            var filteredMonths = self.allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    let photoTakenLocally = photo.editableModel?.isTakenLocally ?? false

                    return photoTakenLocally && determineIncludedInStarAndCache(filterState, model: photo.editableModel)
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                return !month.photos.isEmpty
            }
            self.monthsToDisplay = filteredMonths
        case .screenshots:
            break
        case .all:
            var filteredMonths = self.allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    return determineIncludedInStarAndCache(filterState, model: photo.editableModel)
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                return !month.photos.isEmpty
            }
            self.monthsToDisplay = filteredMonths
//            self.monthsToDisplay = self.allMonths
//            for month in self.allMonths {
//                allPhotosToDisplay += month.photos
//            }
        }
        
//        switch filterState {
//        case .local:
//            var filteredMonths = self.allMonths
//            for index in 0..<filteredMonths.count {
//                let filteredPhotos = filteredMonths[index].photos.filter { photo in
//                    return photo.editableModel?.isTakenLocally ?? false
//                }
//                filteredMonths[index].photos = filteredPhotos
//                allPhotosToDisplay += filteredPhotos
//            }
//            filteredMonths = filteredMonths.filter { month in
//                return !month.photos.isEmpty
//            }
//            self.monthsToDisplay = filteredMonths
//        case .starred:
//            var filteredMonths = self.allMonths
//            for index in 0..<filteredMonths.count {
//                let filteredPhotos = filteredMonths[index].photos.filter { photo in
//                    return photo.editableModel?.isHearted ?? false
//                }
//                filteredMonths[index].photos = filteredPhotos
//                allPhotosToDisplay += filteredPhotos
//            }
//            filteredMonths = filteredMonths.filter { month in
//                return !month.photos.isEmpty
//            }
//            self.monthsToDisplay = filteredMonths
//        case .cached:
//            var filteredMonths = self.allMonths
//            for index in 0..<filteredMonths.count {
//                let filteredPhotos = filteredMonths[index].photos.filter { photo in
//                    return photo.editableModel?.isDeepSearched ?? false
//                }
//                filteredMonths[index].photos = filteredPhotos
//                allPhotosToDisplay += filteredPhotos
//            }
//            filteredMonths = filteredMonths.filter { month in
//                return !month.photos.isEmpty
//            }
//            self.monthsToDisplay = filteredMonths
//        case .all:
//            if TipViews.currentStarStep == 1 {
//                self.startStarSecondStep()
//            }
//            if TipViews.currentCacheStep == 1 {
//                self.startCacheSecondStep()
//            }
//
//            self.monthsToDisplay = self.allMonths
//            for month in self.allMonths {
//                allPhotosToDisplay += month.photos
//            }
//        }
        
        self.allPhotosToDisplay = allPhotosToDisplay
        
        if allPhotosToDisplay.isEmpty {
//            if let previousFilter = previousFilter {
//                showEmptyView(previously: previousFilter, to: filter)
//            } else {
//                showEmptyView(previously: .all, to: filter)
//            }
            findButton.isEnabled = false
            selectButton.isEnabled = false
        } else {
//            hideEmptyView()
            findButton.isEnabled = true
            selectButton.isEnabled = true
        }
    }
}
