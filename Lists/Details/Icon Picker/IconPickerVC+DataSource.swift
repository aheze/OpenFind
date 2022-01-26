//
//  IconPickerVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension IconPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.icons.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.icons[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconPickerCell",
            for: indexPath
        ) as? IconPickerCell else {
            fatalError()
        }
        
        let icon = model.icons[indexPath.section][indexPath.item]
        cell.imageView.image = UIImage(systemName: icon.systemName)
        
        return cell
    }
}

extension IconPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        var (numberOfItems, totalWidth) = (0, CGFloat(0))
        while totalWidth < availableWidth {
            let itemLength = IconPickerConstants.minimumCellWidth
            let spacing = IconPickerConstants.spacing
            numberOfItems += 1
            totalWidth += itemLength + spacing
        }
        
        let totalSpacing = IconPickerConstants.spacing * (CGFloat(numberOfItems) - 1)
        let itemLength = (availableWidth - totalSpacing) / CGFloat(numberOfItems)
        
        print("availableWidth: \(availableWidth), \(totalSpacing) numberOfItems: \(numberOfItems), delegate: \(itemLength)")
        return CGSize(width: itemLength, height: itemLength)
    }
}
