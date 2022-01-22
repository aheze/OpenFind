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
        ) as? ListsContentCell else {
            fatalError()
        }
        
        let list = listsViewModel.displayedLists[indexPath.item]
        cell.headerImageView.image = UIImage(systemName: list.image)
        cell.headerTitleLabel.text = list.name
        cell.headerDescriptionLabel.text = list.desc
        cell.layer.cornerRadius = 16
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.getRelativeContentOffset()
        print("cr: \(contentOffset)")
        searchBarOffset = contentOffset - searchConfiguration.getTotalHeight()
        updateNavigationBar?()
    }
}
