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
        return model.icons[section].icons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconPickerCell",
            for: indexPath
        ) as? IconPickerCell else {
            fatalError()
        }

        let icon = model.icons[indexPath.section].icons[indexPath.item]
        
        if let image = UIImage(systemName: icon) {
            cell.imageView.image = image
            cell.imageView.tintColor = .label
        } else {
            print("Name: \(icon)")
            cell.imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell.imageView.tintColor = .systemYellow
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if
            kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IconPickerHeader", for: indexPath) as? IconPickerHeader
        {
            headerView.label.text = model.icons[indexPath.section].categoryName
            return headerView
        }
        fatalError()
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

        return CGSize(width: itemLength, height: itemLength)
    }
}
