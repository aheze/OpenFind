//
//  ListsVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

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
    
    func boundsChanged(to size: CGSize, safeAreaInset: UIEdgeInsets) {
        let availableWidth = listsFlowLayout.columnWidth
        
        for index in listsViewModel.displayedLists.indices {
            let oldDisplayedList = listsViewModel.displayedLists[index]
            _ = getCellSize(availableWidth: availableWidth, list: oldDisplayedList.list, listIndex: index)
            let newDisplayedList = listsViewModel.displayedLists[index]
            
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                addChipViews(to: cell, with: newDisplayedList)
            }
        }
    }
}
