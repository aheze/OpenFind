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
        let section = PhotoSlidesSection()
        snapshot.appendSections([section])
        snapshot.appendItems(slidesState.photos, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, photo -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PhotosSlidesContentCell",
                    for: indexPath
                ) as! PhotosSlidesContentCell

                cell.contentView.backgroundColor = .green
                return cell
            }
        )
        return dataSource
    }
}
