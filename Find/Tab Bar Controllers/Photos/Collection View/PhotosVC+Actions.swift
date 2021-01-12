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
    func star(_ shouldStar: Bool) {
        print("starring ; \(indexPathsSelected)")
        var changedPhotos = [FindPhoto]()
        if shouldStar {
            for indexPath in indexPathsSelected {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    changedPhotos.append(findPhoto)
                    print("has photo")
                    if let model = findPhoto.model {
                        do {
                            try realm.write {
                                model.isHearted = true
                            }
                        } catch {
                            print("Error starring photo \(error)")
                        }
                    } else {
                        let assetIdentifier = findPhoto.asset.localIdentifier
                        let newModel = HistoryModel()
                        newModel.assetIdentifier = assetIdentifier
                        newModel.isHearted = true
                        newModel.isTakenLocally = false
                        
                        do {
                            try realm.write {
                                realm.add(newModel)
                            }
                        } catch {
                            print("Error saving model \(error)")
                        }
                        
                        findPhoto.model = newModel
                    }
                }
            }
            applyModelSnapshot(changedItems: changedPhotos)
        } else {
            print("nop star")
        }
        deselectAllPhotos()
    }
}
