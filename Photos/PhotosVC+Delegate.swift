//
//  PhotosVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

/// Scroll view
extension PhotosViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBlur(with: scrollView)
        
        /// For photos caching
        updateCachedAssets()
        
        if let resultsState = model.resultsState {
            let oldIndices = resultsState.displayedIndices
            let newIndices = Set(resultsCollectionView.indexPathsForVisibleItems.map { $0.item })
            model.resultsState?.displayedIndices = newIndices
            
            let removedIndices = oldIndices.subtracting(newIndices)
            if removedIndices.count >= 1 {
                print("Removed: \(removedIndices)")
            }
            resultsCellIndicesDisappeared(indices: removedIndices)
        }
    }
    
    /// update the blur with a scroll view's content offset
    func updateNavigationBlur(with scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }
    
    /// called when the cells disappear, since `didEndDisplayingCell` doesn't work
    func resultsCellIndicesDisappeared(indices: Set<Int>) {
        for index in indices {
            print("Index: \(index)")
            if let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell {
                didEndDisplayingResultsCell(cell: cell, index: index)
            }
        }
    }
}
