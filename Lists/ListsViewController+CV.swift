//
//  ListsViewController+CV.swift
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
}
