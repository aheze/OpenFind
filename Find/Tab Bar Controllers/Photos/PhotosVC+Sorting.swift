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
    
//    func copy(with zone: NSZone? = nil) -> Any {
//        let copy = Month()
//        copy.id = id
//        copy.monthDate = monthDate
//        copy.photos = photos
////        copy.hashValue = hashValue
//        return copy
//    }
    
//    var id = UUID()
//    var monthDate = Date()
////    var assets = [PHAsset]()
//    var photos = [FindPhoto]()
    var id = UUID()
    var monthDate: Date
//    var assets = [PHAsset]()
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
    var model: HistoryModel?
    
    func hash(into hasher: inout Hasher) {
      // 2
      hasher.combine(id)
    }
    // 3
    static func == (lhs: FindPhoto, rhs: FindPhoto) -> Bool {
      lhs.id == rhs.id
    }
}



extension PhotosViewController {
    func getSliderCallback() {
        segmentedSlider.pressedFilter = { [weak self] filter in
            print("presed fil")
            guard let self = self else { return }
            switch filter {
            case .local:
                
//                var filteredSections = [Month]()
//                for month in self.allMonths {
//                    let newMonth = month.copy() as! Month
//                    filteredSections.append(newMonth)
//                }
                var filteredMonths = self.allMonths
//                filteredMonths = filteredMonths.filter { month in
//
//                    let filteredPhotos = month.photos.filter { photo in
//                        return photo.model?.isTakenLocally ?? false
//                    }
//                    month.photos = filteredPhotos
//                    return !filteredPhotos.isEmpty
//                }
                
                for index in 0..<filteredMonths.count {
//                    var month = filteredMonths[index]
                    let filteredPhotos = filteredMonths[index].photos.filter { photo in
                        return photo.model?.isTakenLocally ?? false
                    }
                   filteredMonths[index].photos = filteredPhotos
                    
                }
                filteredMonths = filteredMonths.filter { month in
                    
                    let filteredPhotos = month.photos.filter { photo in
                        return photo.model?.isTakenLocally ?? false
                    }
                    return !filteredPhotos.isEmpty
                }
//                var filteredPhotoArray = [FindPhoto]()
//                filteredSections.forEach { (month) in
                    
//                    let filteredPhotos = month.photos.filter { photo in
//                        return photo.model?.isTakenLocally ?? false
//                    }
//                    let newMont
//
//                }
                self.monthsToDisplay = filteredMonths
//
//                self.monthsToDisplay.forEach { (month) in
//                    month.photos = month.photos.filter { photo in
//                        return photo.model?.isTakenLocally ?? false
//
//                    }
//
//                }
//                var newMonths = [Month]()
//                for month in self.allMonths {
//
//
//                    let newMonth = Month()
//                    newMonth.id = month.id
//                    newMonth.photos = month.photos.filter { photo in
//                        return photo.model?.isTakenLocally ?? false
//                    }
//
//                    newMonths.append(newMonth)
//                }
//                self.monthsToDisplay = newMonths.filter { month in
//                    return !month.photos.isEmpty
//                }
                
                
//                var newMonths = [Month]()
//
//                for month in self.allMonths {
//                    let sortedMonth = Month()
//                    sortedMonth.monthDate = month.monthDate
//                    for photo in month.photos {
//                        if let model = photo.model,
//                           model.isTakenLocally {
//                            sortedMonth.photos.append(photo)
//                        }
//                    }
//                    if !sortedMonth.photos.isEmpty {
//                        newMonths.append(sortedMonth)
//                    }
//                }
                
//                self.monthsToDisplay = newMonths
            case .starred:
                print("starred")
                var filteredMonths = self.allMonths
                for index in 0..<filteredMonths.count {
//                    var month = filteredMonths[index]
                    let filteredPhotos = filteredMonths[index].photos.filter { photo in
                        return photo.model?.isHearted ?? false
                    }
                   filteredMonths[index].photos = filteredPhotos
                    
                }
                filteredMonths = filteredMonths.filter { month in
                    
                    let filteredPhotos = month.photos.filter { photo in
                        return photo.model?.isHearted ?? false
                    }
                    return !filteredPhotos.isEmpty
                }
                self.monthsToDisplay = filteredMonths
//                var newMonths = [Month]()
//
//                for month in self.allMonths {
//                    let sortedMonth = Month()
//                    sortedMonth.monthDate = month.monthDate
//                    for photo in month.photos {
//                        if let model = photo.model,
//                           model.isHearted {
//                            sortedMonth.photos.append(photo)
//                        }
//                    }
//                    if !sortedMonth.photos.isEmpty {
//                        newMonths.append(sortedMonth)
//                    }
//                }
//
//                self.monthsToDisplay = newMonths
//                var newMonths = self.allMonths
//                let allMonths = self.allMonths
//                let filteredSections = allMonths.filter { month in
//
//                    let filteredPhotos = month.photos.filter { photo in
//                        return photo.model?.isTakenLocally ?? false
//                    }
//
//                    return !filteredPhotos.isEmpty
//                }
//                for month in newMonths {
//                    month.photos = month.photos.filter { photo in
//                        return photo.model?.isHearted ?? false
//                    }
//                }
//                self.monthsToDisplay = newMonths.filter { month in
//                    return !month.photos.isEmpty
//                }
            case .cached:
                print("cached")
                var filteredMonths = self.allMonths
                for index in 0..<filteredMonths.count {
//                    var month = filteredMonths[index]
                    let filteredPhotos = filteredMonths[index].photos.filter { photo in
                        return photo.model?.isDeepSearched ?? false
                    }
                   filteredMonths[index].photos = filteredPhotos
                    
                }
                filteredMonths = filteredMonths.filter { month in
                    
                    let filteredPhotos = month.photos.filter { photo in
                        return photo.model?.isDeepSearched ?? false
                    }
                    return !filteredPhotos.isEmpty
                }
                self.monthsToDisplay = filteredMonths
//                var newMonths = [Month]()
//
//                for month in self.allMonths {
//                    let sortedMonth = Month()
//                    sortedMonth.monthDate = month.monthDate
//                    for photo in month.photos {
//                        if let model = photo.model,
//                           model.isDeepSearched {
//                            sortedMonth.photos.append(photo)
//                        }
//                    }
//                    if !sortedMonth.photos.isEmpty {
//                        newMonths.append(sortedMonth)
//                    }
//                }
//
//                self.monthsToDisplay = newMonths
            case .all:
                self.monthsToDisplay = self.allMonths
            }
            
            self.applySnapshot(animatingDifferences: true)
        }
    }
//    func filteredSections() -> [Section] {
//      let sections = Section.allSections
//      guard
//        let query = queryOrNil,
//        !query.isEmpty
//        else {
//          return sections
//      }
//
//      return sections.filter { section in
//        var matches = section.title.lowercased().contains(query.lowercased())
//        for video in section.videos {
//          if video.title.lowercased().contains(query.lowercased()) {
//            matches = true
//            break
//          }
//        }
//        return matches
//      }
//    }
}
