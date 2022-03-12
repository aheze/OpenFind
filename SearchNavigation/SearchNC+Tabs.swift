//
//  SearchNC+Tabs.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SearchNavigationController {
    func willBecomeActive() {
        model.onWillBecomeActive?()
    }
    
    func didBecomeActive() {
        model.onDidBecomeActive?()
    }
    
    func willBecomeInactive() {
        model.onWillBecomeInactive?()
    }
    
    func didBecomeInactive() {
        model.onDidBecomeInactive?()
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        model.onBoundsChange?(size, safeAreaInsets)
    }
}
