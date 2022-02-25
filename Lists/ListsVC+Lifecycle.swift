//
//  ListsVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// All called manually via `ListsController`
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
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        /// get width of columns based on new size
        let (_, columnWidth) = listsFlowLayout.getColumns(bounds: size.width, insets: safeAreaInsets)
        
        for index in model.displayedLists.indices {
            _ = getCellSize(listIndex: index, availableWidth: columnWidth)
            let newDisplayedList = model.displayedLists[index]
            
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                addChipViews(to: cell, with: newDisplayedList)
            }
        }
        
        self.baseSearchBarOffset = self.getCompactBarSafeAreaHeight(with: safeAreaInsets)
        self.updateNavigationBar?()
        
        detailsViewController?.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)

    }
}
