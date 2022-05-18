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
            /// make sure that views are loaded inside here
            resetSelectingState()
        }
    }
    
    func didBecomeInactive() {}
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateNavigationBar?()
        
        if let displayedFindPhotos = model.resultsState?.displayedFindPhotos {
            let (_, columnWidth) = resultsFlowLayout.getColumns(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)
            
            DispatchQueue.global(qos: .userInitiated).async {
                let sizes = self.getDisplayedCellSizes(from: displayedFindPhotos, columnWidth: columnWidth)
                
                DispatchQueue.main.async {
                    self.model.resultsState?.displayedCellSizes = sizes
                    self.resultsFlowLayout.invalidateLayout()
                }
            }
        }
        
        if let slidesState = model.slidesState {
            slidesState.viewController?.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
        }
    }
}
