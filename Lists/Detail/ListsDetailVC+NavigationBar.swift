//
//  ListsDetailVC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ListsDetailViewController {
    func setupNavigationBar() {
        if #available(iOS 14.0, *) {
            let shareAction = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                guard let self = self else { return }
                let list = self.model.list.getList()
                if let url = list.getURL() {
                    let dataSource = ListsSharingDataSource(lists: [list])
                    self.presentShareSheet(items: [url, dataSource])
                }
            }
            
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteList()
            }
            
            let optionsButton = UIBarButtonItem(
                title: "",
                image: UIImage(systemName: "ellipsis"),
                menu: UIMenu(title: "", children: [
                    shareAction,
                    deleteAction
                ])
            )
            
            if model.addDismissButton {
                navigationItem.leftBarButtonItem = optionsButton
                navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.dismissSelf), imageName: "Dismiss")
            } else {
                navigationItem.rightBarButtonItem = optionsButton
            }
            
        } else {
            let optionsButton = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: self,
                action: #selector(self.optionsPressed)
            )
            
            if model.addDismissButton {
                navigationItem.leftBarButtonItem = optionsButton
                navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.dismissSelf), imageName: "Dismiss")
            } else {
                navigationItem.rightBarButtonItem = optionsButton
            }
        }
    }

    @objc func optionsPressed() {}
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
    func deleteList() {
        let listName = model.list.title.isEmpty ? "This List" : #""\#(model.list.title)""#
        let alert = UIAlertController(title: "Delete \(listName)?", message: "Are you sure you want to delete this list? This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.model.listDeleted?(self.model.list.getList())
                
                if self.model.addDismissButton {
                    self.dismiss(animated: true)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        present(alert, animated: true, completion: nil)
    }
}
