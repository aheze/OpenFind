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
            selectionMode = true
        } else {
            selectionMode = false
        }
    }
    
}


