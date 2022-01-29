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
        listsViewModel.displayedLists = realmModel.lists.map { .init(list: $0) }.sorted(by: { $0.list.dateCreated > $1.list.dateCreated })
        collectionView.reloadData()
    }
}

extension ListsViewController {
    /// single list updated
    func listUpdated(list: List) {
        if let firstIndex = listsViewModel.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
            listsViewModel.displayedLists[firstIndex].list = list
            collectionView.reloadItems(at: [firstIndex.indexPath])
        }
    }

    func addNewList() {
        let newList = List()
        realmModel.addList(list: newList)
        listsViewModel.displayedLists = realmModel.lists.map { .init(list: $0) }.sorted(by: { $0.list.dateCreated > $1.list.dateCreated })
        if let index = listsViewModel.displayedLists.firstIndex(where: { $0.list.id == newList.id }) {
            collectionView.insertItems(at: [index.indexPath])
        }
        presentDetails(list: newList)
    }
}
