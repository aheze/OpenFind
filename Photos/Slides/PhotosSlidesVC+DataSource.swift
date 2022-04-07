//
//  PhotosSlidesVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func update(animate: Bool = true) {
        guard let slidesState = model.slidesState else { return }
        var snapshot = Snapshot()
        let section = DataSourceSectionTemplate()
        snapshot.appendSections([section])
        snapshot.appendItems(slidesState.slidesPhotos, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: animate)
    }

    func makeDataSource() -> DataSource? {
        guard let collectionView = collectionView else { return nil }
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, photo -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotosSlidesContentCell",
                for: indexPath
            ) as! PhotosSlidesContentCell
            
            print("indexpath: \(indexPath)")
            cell.contentView.transform = .identity
            cell.contentView.alpha = 1
            
            self.display(cell: cell, indexPath: indexPath)

            return cell
        }

        return dataSource
    }
}
