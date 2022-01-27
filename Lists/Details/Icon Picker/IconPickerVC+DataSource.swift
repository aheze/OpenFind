//
//  IconPickerVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IconPickerViewController {
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, icon -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "IconPickerCell",
                    for: indexPath
                ) as! IconPickerCell

                if let image = UIImage(systemName: icon) {
                    cell.imageView.image = image
                    cell.imageView.tintColor = .label
                } else {
                    cell.imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
                    cell.imageView.tintColor = .systemYellow
                }

                return cell
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if
                kind == UICollectionView.elementKindSectionHeader,
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IconPickerHeader", for: indexPath) as? IconPickerHeader
            {
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//                print("section: \(indexPath.section), name: \(self.model.icons[indexPath.section].categoryName)")
                headerView.label.text = section.categoryName
                return headerView
            }

            return nil
        }

        return dataSource
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
