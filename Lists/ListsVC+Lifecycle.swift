//
//  ListsVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

/// All called manually via `ListsController`
extension ListsViewController {
    func willBecomeActive() {
        detailsViewController?.willBecomeActive()
    }
    
    func didBecomeActive() {
        detailsViewController?.didBecomeActive()
        
        /// add lists if already launched
        if realmModel.launchedBefore, !realmModel.addedListsBefore {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                let alert = UIAlertController(title: "Sample Lists Available!", message: "Find v2.0 comes with new sample lists. Would you like to add them?", preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "Add Sample Lists", style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        self.realmModel.addSampleLists()
                    }
                )
                alert.addAction(
                    UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                        guard let self = self else { return }
                        self.realmModel.addedListsBefore = true
                    }
                )
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func willBecomeInactive() {
        withAnimation {
            if model.loaded {
                resetSelectingState()
            }
        }
        detailsViewController?.willBecomeInactive()
    }
    
    func didBecomeInactive() {
        detailsViewController?.didBecomeInactive()
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        /// get width of columns based on new size
        let (_, columnWidth) = listsFlowLayout.getColumns(bounds: size.width, insets: safeAreaInsets)
        
        for index in model.displayedLists.indices {
            _ = writeCellFrameAndReturnSize(index: index, availableWidth: columnWidth)
            let newDisplayedList = model.displayedLists[index]
            
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                cell.view.addChipViews(with: newDisplayedList.list, chipFrames: newDisplayedList.frame.chipFrames)
            }
        }
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffsetFromScroll(scrollView: collectionView)
        detailsViewController?.boundsChanged(to: size, safeAreaInsets: safeAreaInsets)
    }
}
