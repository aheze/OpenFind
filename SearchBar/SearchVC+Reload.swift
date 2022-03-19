//
//  SearchVC+Reload.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
    /// update the collection view.
    func reload() {
        searchCollectionViewFlowLayout.invalidateLayout()
        searchCollectionView.reloadData()
        searchCollectionView.layoutIfNeeded()

        if let focusedIndex = collectionViewModel.focusedCellIndex {
            let targetOrigin = searchCollectionViewFlowLayout.getPointForCell(at: focusedIndex)

            searchCollectionView.contentOffset = CGPoint(x: 0.5, y: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                self.searchCollectionView.contentOffset = targetOrigin
            }
        }
    }
}
