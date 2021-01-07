//
//  PhotosVC+Sorting.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

class Month: Hashable {
    
    var id = UUID()
    var monthDate = Date()
//    var assets = [PHAsset]()
    var photos = [FindPhoto]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
    
}

class FindPhoto: NSObject {
    var asset = PHAsset()
    var model = HistoryModel()
}


extension PhotosViewController {
    func getSliderCallback() {
        segmentedSlider.pressedFilter = { [weak self] filter in
            print("presed fil")
            guard let self = self else { return }
            switch filter {
            case .local:
                var newMonths = [Month]()
                
                for month in self.allMonths {
                    let sortedMonth = Month()
                    sortedMonth.monthDate = month.monthDate
                    for photo in month.photos {
                        if photo.model.isTakenLocally {
                            sortedMonth.photos.append(photo)
                        }
                    }
                    if !sortedMonth.photos.isEmpty {
                        newMonths.append(sortedMonth)
                    }
                }
                
                self.monthsToDisplay = newMonths
            case .starred:
                print("starred")
            case .cached:
                print("cached")
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
