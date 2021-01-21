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
}
