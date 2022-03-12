//
//  PhotosVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension PhotosViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }
    
    func didBecomeInactive() {}
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        self.baseSearchBarOffset = self.getCompactBarSafeAreaHeight(with: safeAreaInsets)
        self.updateNavigationBar?()
        
        if let slidesState = model.slidesState {
            slidesState.viewController?.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
        }
    }
}
