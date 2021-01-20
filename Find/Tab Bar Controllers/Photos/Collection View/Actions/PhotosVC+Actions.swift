//
//  PhotosVC+Actions.swift
//  Find
//
//  Created by Zheng on 1/12/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import RealmSwift

extension PhotosViewController {
    func applyModelSnapshot(changedItems: [FindPhoto]) {
        var snapshot = Snapshot()
        snapshot.appendSections(monthsToDisplay)
        monthsToDisplay.forEach { month in
            snapshot.appendItems(month.photos, toSection: month)
        }
        snapshot.reloadItems(changedItems)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
//    func reloadSnapshot(at indexPaths: [IndexPath]) {
//        var snapshot = Snapshot()
//        snapshot.appendSections(monthsToDisplay)
//        monthsToDisplay.forEach { month in
//            snapshot.appendItems(month.photos, toSection: month)
//        }
//        snapshot.rea
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
    func slidesChanged(at index: Int) {
        print("slides changed at \(index)")
        let findPhoto = allPhotosToDisplay[index]
        if let indexPath = dataSource.indexPath(for: findPhoto) {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                if let model = findPhoto.editableModel {
                    if model.isDeepSearched {
                        cell.cacheImageView.image = UIImage(named: "CacheActive-Light")
                    } else {
                        cell.cacheImageView.image = nil
                    }
                    if model.isHearted {
                        cell.starImageView.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
                    } else {
                        cell.starImageView.image = nil
                    }
                    if model.isDeepSearched || model.isHearted {
                        cell.shadowImageView.image = UIImage(named: "DownShadow")
                    } else {
                        cell.shadowImageView.image = nil
                    }
                } else {
                    cell.cacheImageView.image = nil
                    cell.starImageView.image = nil
                    cell.shadowImageView.image = nil
                }
                sortPhotos(with: currentFilter)
                applySnapshot(animatingDifferences: true)
            }
        }
    }
}
