//
//  ListsVC+Realm.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/28/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import UIKit

extension ListsViewController {
    func listenToListsChange() {
        realmModel.$lists
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async { /// get `didSet`
                    self.reload()
                }
            }
            .store(in: &realmModel.cancellables)
    }

    func reload() {
        reloadDisplayedLists()
        update(animate: false)
    }

    func reloadDisplayedLists() {
        if model.isFinding {
            let search = searchViewModel.text
            find(text: search)
        } else {
            let displayedLists = realmModel.lists.map { DisplayedList(list: $0) }
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

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = CGRect(
                x: view.bounds.width - 50,
                y: view.bounds.height - tabViewModel.tabBarAttributes.backgroundHeight,
                width: 50,
                height: 50
            )
        }

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
