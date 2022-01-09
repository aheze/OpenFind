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
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = abs(min(0, scrollView.contentOffset.y))
        let topSafeArea = scrollView.adjustedContentInset.top
        
        /// rubber banding on large title
        if offset > topSafeArea {
            searchContainerViewTopC.constant = offset
        } else {
            searchContainerViewTopC.constant = topSafeArea
        }
        
        updateBlur()
    }
}

extension UINavigationBar {
    func getCompactHeight() -> CGFloat {
        
        /// Loop through the navigation bar's subviews.
        for subview in subviews {
            
            /// Check if the subview is pinned to the top (compact bar) and contains a title label
            if subview.frame.origin.y == 0 && subview.subviews.contains(where: { $0 is UILabel }) {
                return subview.bounds.height
            }
        }
        
        return 0
    }
}
