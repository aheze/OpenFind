//
//  ListsVC+Realm.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController: RealmModelListener {
    func listsUpdated() {
        listsViewModel.displayedLists = realmModel.lists.map { .init(list: $0) }
        collectionView.reloadData()
    }
}
