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
            ) { _ in
                
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
            
            navigationItem.rightBarButtonItem = optionsButton
        } else {
            let optionsButton = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: self,
                action: #selector(optionsPressed)
            )
            navigationItem.rightBarButtonItem = optionsButton
        }
    }

    @objc func optionsPressed() {}
    
    func deleteList() {
        let listName = model.list.name.isEmpty ? "This List" : #""\#(model.list.name)""#
        let alert = UIAlertController(title: "Delete \(listName)?", message: "Are you sure you want to delete this list? This can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.model.listDeleted?(self.model.list.getList())
                self.navigationController?.popViewController(animated: true)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        present(alert, animated: true, completion: nil)
    }
}
