//
//  ListsVC+CV.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = searchConfiguration.getTotalHeight()
        collectionView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
    }
}

extension ListsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listsViewModel.displayedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Cell",
            for: indexPath
        ) as? ListContentCell else {
            fatalError()
        }
        
        cell.contentView.addDebugBorders(.blue)
        cell.layer.cornerRadius = 16
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.getRelativeContentOffset()
        searchBarOffset = contentOffset - searchConfiguration.getTotalHeight()
        updateNavigationBar?()
    }
}
