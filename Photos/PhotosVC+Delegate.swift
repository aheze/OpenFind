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
    }
    
    /// update the blur with a scroll view's content offset
    func updateNavigationBlur(with scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotosResultsCell {
            willDisplayResultsCell(cell: cell, index: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotosResultsCell {
            didEndDisplayingResultsCell(cell: cell, index: indexPath.item)
        }
    }
}
