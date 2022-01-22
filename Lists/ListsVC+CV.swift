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
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
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
        
        let list = listsViewModel.displayedLists[indexPath.item].list
        cell.headerView.backgroundColor = UIColor(hex: list.color)
        cell.headerImageView.image = UIImage(systemName: list.image)
        cell.headerTitleLabel.text = list.name
        cell.headerDescriptionLabel.text = list.desc
        cell.layer.cornerRadius = ListsCellConstants.cornerRadius
        cell.tapped = { [weak self] in
            guard let self = self else { return }
            if let list = self.listsViewModel.displayedLists[safe: indexPath.item]?.list {
                self.presentDetails(list: list)
            }
        }
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListsContentCell else {
            fatalError()
        }
        
        cell.chipsContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let displayedList = listsViewModel.displayedLists[indexPath.item]
        let frame = displayedList.frame
        
        for chipFrame in frame.chipFrames {
            let chipView = ListChipView(isWordsLeftButton: chipFrame.isWordsLeftButton)
            chipView.frame = chipFrame.frame
            chipView.label.text = chipFrame.string
            chipView.label.textColor = UIColor(hex: displayedList.list.color)
            if chipFrame.isWordsLeftButton {
                chipView.backgroundView.backgroundColor = UIColor(hex: displayedList.list.color).withAlphaComponent(0.1)
                chipView.tapped = { [weak self] in
                    guard let self = self else { return }
                    if let list = self.listsViewModel.displayedLists[safe: indexPath.item]?.list {
                        self.presentDetails(list: list)
                    }
                }
            } else {
                chipView.backgroundView.backgroundColor = ListsCellConstants.chipBackgroundColor
            }
            cell.chipsContainerView.addSubview(chipView)
        }
        
    }
}

/// Scroll view
extension ListsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.getRelativeContentOffset()
        searchBarOffset = contentOffset - searchConfiguration.getTotalHeight()
        updateNavigationBar?()
    }
}
