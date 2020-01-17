//
//  HistoryStartSelection.swift
//  Find
//
//  Created by Andrew on 1/10/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension NewHistoryViewController {
    
    func enterSelectMode(entering: Bool) {
//        guard !dictOfUrls.isEmpty else {
//            return
//        }
//
//        guard !fileUrlsSelected.isEmpty else {
//          selectionMode.toggle()
//          return
//        }
//
//        guard selectionMode else {
//          return
//        }
        if entering == true {
//            for cellPath in dictOfUrls {
//                let section = cellPath.key.section
//                let row = cellPath.key.row
//                let indexPath = IndexPath(item: row, section: section)
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
//                cell.selectMode = true
//            }
            selectionMode = true
        } else {
            selectionMode = false
//            for cellPath in dictOfUrls {
//                let section = cellPath.key.section
//                let row = cellPath.key.row
//                let indexPath = IndexPath(item: row, section: section)
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
//                cell.selectMode = false
//            }
        }
    }
    
}


