//
//  ListsVC+Realm.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func setupRealm() {
        model.deleteSelected = { [weak self] in
            guard let self = self else { return }
            self.deleteSelectedLists()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(listsUpdated),
            name: .listsUpdated,
            object: nil
        )
    }
    
    @objc func listsUpdated(notification: Notification) {
        
    }

    func reload() {
        reloadDisplayedLists()
        collectionView.reloadData()
    }
    func reloadDisplayedLists() {
        model.displayedLists = realmModel.lists.map { .init(list: $0) }.sorted(by: { $0.list.dateCreated > $1.list.dateCreated })
    }

    func deleteSelectedLists() {
        let listName = model.selectedLists.count == 1 ? "1 List" : "\(model.selectedLists.count) Lists"
        let alert = UIAlertController(title: "Delete \(listName)?", message: "This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.deleteLists(lists: self.model.selectedLists)
                self.model.isSelecting = false
                self.updateCollectionViewSelectionState()
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        present(alert, animated: true, completion: nil)
    }

    func deleteLists(lists: [List]) {
        var indices = [Int]()
        for list in lists {
            if let firstIndex = model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
                indices.append(firstIndex)
                realmModel.deleteList(list: list)
            }
        }

        let indexPaths = indices.map { $0.indexPath }
        reloadDisplayedLists()
        collectionView.deleteItems(at: indexPaths)
    }
}

extension ListsViewController {
    /// single list updated
    func listUpdated(list: List) {
        if let firstIndex = model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
            model.displayedLists[firstIndex].list = list
            collectionView.reloadItems(at: [firstIndex.indexPath])
        }
    }

    func addNewList() {
        let newList = List()
        realmModel.addList(list: newList)
        reloadDisplayedLists()
        if let index = model.displayedLists.firstIndex(where: { $0.list.id == newList.id }) {
            collectionView.insertItems(at: [index.indexPath])
        }
        presentDetails(list: newList)
    }

    func listDeleted(list: List) {
        if let firstIndex = model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
            model.displayedLists.remove(at: firstIndex)
            collectionView.deleteItems(at: [firstIndex.indexPath])
        }
    }
}
