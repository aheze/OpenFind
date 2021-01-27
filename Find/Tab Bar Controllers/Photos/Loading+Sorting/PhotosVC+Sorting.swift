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
        segmentedSlider.pressedFilter = { [weak self] filter in
            guard let self = self else { return }
            self.sortPhotos(from: self.currentFilter, with: filter)
            self.currentFilter = filter
            self.applySnapshot(animatingDifferences: true)
        }
    }
    func sortPhotos(from previousFilter: PhotoFilter? = nil, with filter: PhotoFilter) {
        var allPhotosToDisplay = [FindPhoto]()
        
        switch filter {
        case .local:
            var filteredMonths = self.allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    return photo.editableModel?.isTakenLocally ?? false
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                return !month.photos.isEmpty
            }
            self.monthsToDisplay = filteredMonths
        case .starred:
            var filteredMonths = self.allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    return photo.editableModel?.isHearted ?? false
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                return !month.photos.isEmpty
            }
            self.monthsToDisplay = filteredMonths
        case .cached:
            var filteredMonths = self.allMonths
            for index in 0..<filteredMonths.count {
                let filteredPhotos = filteredMonths[index].photos.filter { photo in
                    return photo.editableModel?.isDeepSearched ?? false
                }
                filteredMonths[index].photos = filteredPhotos
                allPhotosToDisplay += filteredPhotos
            }
            filteredMonths = filteredMonths.filter { month in
                return !month.photos.isEmpty
            }
            self.monthsToDisplay = filteredMonths
        case .all:
            self.monthsToDisplay = self.allMonths
            for month in self.allMonths {
                allPhotosToDisplay += month.photos
            }
        }
        
        self.allPhotosToDisplay = allPhotosToDisplay
        
        if allPhotosToDisplay.isEmpty {
            if let previousFilter = previousFilter {
                showEmptyView(previously: previousFilter, to: filter)
            } else {
                showEmptyView(previously: .all, to: filter)
            }
            findButton.isEnabled = false
            selectButton.isEnabled = false
        } else {
            hideEmptyView()
            findButton.isEnabled = true
            selectButton.isEnabled = true
        }
    }
}
