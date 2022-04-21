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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIAccessibility.post(notification: .screenChanged, argument: self.searchContainerView)
        }
    }
    
    func willBecomeInactive() {
        model.onWillBecomeInactive?()
    }
    
    func didBecomeInactive() {
        model.onDidBecomeInactive?()
    }
    
    /// don't use this because search navigation controller doesn't need to be a tab
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {}
}
