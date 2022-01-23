//
//  ListsVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import Foundation

extension ListsViewController {
    func willBecomeActive() {
        detailsViewController?.willBecomeActive()
    }
    
    func didBecomeActive() {
        detailsViewController?.didBecomeActive()
    }
    
    func willBecomeInactive() {
        detailsViewController?.willBecomeInactive()
    }
    
    func didBecomeInactive() {
        detailsViewController?.didBecomeInactive()
    }
}
