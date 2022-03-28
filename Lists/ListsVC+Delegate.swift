//
//  ListsVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// Scroll view
extension ListsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        self.additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }

    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        if model.isSelecting {
            return true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.isSelecting {
            listSelected(at: indexPath)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if model.isSelecting {
            listDeselected(at: indexPath)
        }
    }
}
