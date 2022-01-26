//
//  IconPickerVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

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

        return CGSize(width: itemLength, height: itemLength)
    }
}
