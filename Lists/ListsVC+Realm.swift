//
//  ListsVC+Realm.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    /// call this in `Find-New`'s `viewDidLoad`, after loading realm
    func reload() {
        reloadDisplayedLists()
        update(animate: false)
    }

    func reloadDisplayedLists() {
        guard let sortBy = Settings.Values.ListsSortByLevel(rawValue: realmModel.listsSortBy) else {
            let displayedLists: [DisplayedList] = realmModel.lists.map { .init(list: $0) }
            model.updateDisplayedLists(to: displayedLists)
            return
        }

        /// newest first
        switch sortBy {
        case .newestFirst:
            let displayedLists: [DisplayedList] = realmModel.lists
                .sorted { $0.dateCreated > $1.dateCreated }
                .map { .init(list: $0) }
            model.updateDisplayedLists(to: displayedLists)
        case .oldestFirst:
            let displayedLists: [DisplayedList] = realmModel.lists
                .sorted { $0.dateCreated < $1.dateCreated }
                .map { .init(list: $0) }
            model.updateDisplayedLists(to: displayedLists)
        case .title:
            let displayedLists: [DisplayedList] = realmModel.lists
                .sorted {
                    let a = $0.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let b = $1.displayedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    return a < b
                }
                .map { .init(list: $0) }
            model.updateDisplayedLists(to: displayedLists)
        }
    }

    func deleteSelectedLists() {
        let listName = model.selectedLists.count == 1 ? "1 List" : "\(model.selectedLists.count) Lists"
        let alert = UIAlertController(title: "Delete \(listName)?", message: "This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.deleteLists(lists: self.model.selectedLists)
                    self.resetSelectingState()
                }
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        present(alert, animated: true, completion: nil)
    }

    func deleteLists(lists: [List]) {
        for list in lists {
            realmModel.container.deleteList(list: list)
        }

        reloadDisplayedLists()
        update()
    }
}

/// these are called after realm has updated
extension ListsViewController {
    /// single list updated
    func listUpdated(list: List) {
        if let firstIndex = model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
            var displayedList = model.displayedLists[firstIndex]
            displayedList.list = list
            model.updateDisplayedList(at: firstIndex, with: displayedList)
            update(at: firstIndex.indexPath, with: model.displayedLists[firstIndex])
        }
    }

    /// single list deleted
    func listDeleted(list: List) {
        if let firstIndex = model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
            model.removeDisplayedList(at: firstIndex)
            update()
        }
    }
}
