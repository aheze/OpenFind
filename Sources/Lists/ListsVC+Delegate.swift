//
//  ListsVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListsContentCell else {
            fatalError()
        }

        let displayedList = model.displayedLists[indexPath.item]
        cell.view.addChipViews(with: displayedList.list, chipFrames: displayedList.frame.chipFrames) { [weak self] focus in
            if let displayedList = self?.model.displayedLists.first(where: { $0.list.id == displayedList.list.id }) {
                self?.presentDetails(list: displayedList.list, focusFirstWord: true)
            }
        }
    }

    func updateCellColors() {
        for index in model.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                for case let subview as ListChipView in cell.view.chipsContainerView.subviews {
                    subview.setColors()
                }
            }
        }
    }
}

/// Scroll view
extension ListsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSearchBarOffsetFromScroll(scrollView: scrollView)
    }

    func updateSearchBarOffsetFromScroll(scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
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
