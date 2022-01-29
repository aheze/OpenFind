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
        onWillBecomeActive?()
    }
    
    func didBecomeActive() {
        onDidBecomeActive?()
    }
    
    func willBecomeInactive() {
        onWillBecomeInactive?()
    }
    
    func didBecomeInactive() {
        onDidBecomeInactive?()
    }
    
    func boundsChanged(to size: CGSize, safeAreaInset: UIEdgeInsets) {
        onBoundsChange?(size, safeAreaInset)
    }
}
