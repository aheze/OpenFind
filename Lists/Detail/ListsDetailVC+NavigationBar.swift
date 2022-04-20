//
//  ListsDetailVC+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import Popovers
import UIKit

extension ListsDetailViewController {
    func setupNavigationBar() {
//        if #available(iOS 14.0, *) {
//            setupTopMenu()
//        } else {
            setupPopoversTopMenu()
//        }
        setupDismissButton()
    }
    
    /// sharing logic inside `ListsSharingDataSource`
    func share() {
        let list = model.list.getList()
        if let url = list.getURL() {
            let dataSource = ListsSharingDataSource(lists: [list])
            presentShareSheet(items: [url, dataSource], applicationActivities: nil)
        }
    }
    
    func delete() {
        deleteList()
    }
    
    @available(iOS 14.0, *)
    func setupTopMenu() {
        let shareAction = UIAction(
            title: "Share",
            image: UIImage(systemName: "square.and.arrow.up")
        ) { [weak self] _ in
            self?.share()
        }
        
        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.delete()
        }
        
        let optionsButton = UIBarButtonItem(
            title: "",
            image: UIImage(systemName: "ellipsis"),
            menu: UIMenu(title: "", children: [
                shareAction,
                deleteAction
            ])
        )
        optionsButton.accessibilityLabel = "Options"
        
        if model.addDismissButton {
            navigationItem.leftBarButtonItem = optionsButton
        } else {
            navigationItem.rightBarButtonItem = optionsButton
        }
    }
    
    func setupPopoversTopMenu() {
        let optionsButton: UIButton = {
            let optionsButton = UIButton(type: .system)
            optionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            optionsButton.addTarget(self, action: #selector(popoversBarButtonTapped), for: .touchUpInside)
            return optionsButton
        }()
        optionsButton.accessibilityLabel = "Options"
        popoversOptionsButton = optionsButton
        
        let optionsButtonItem = UIBarButtonItem(customView: optionsButton)
        
        let anchor: Popover.Attributes.Position.Anchor
        if model.addDismissButton {
            navigationItem.leftBarButtonItem = optionsButtonItem
            anchor = .topLeft
        } else {
            navigationItem.rightBarButtonItem = optionsButtonItem
            anchor = .topRight
        }
        
        let popoversMenu = Templates.UIKitMenu(
            sourceView: optionsButton
        ) {
            $0.scaleAnchor = anchor
        } content: {
            Templates.MenuButton(title: "Share", systemImage: "square.and.arrow.up") { [weak self] in
                self?.share()
            }
            Templates.MenuButton(title: "Delete", systemImage: "trash") { [weak self] in
                self?.delete()
            }
            .foregroundColor(.red)
        } fadeLabel: { fade in
            UIView.animate(withDuration: 0.15) {
                optionsButton.alpha = fade ? 0.5 : 1
            }
        }
        self.popoversMenu = popoversMenu
    }
    
    @objc func popoversBarButtonTapped() {
        guard let popoversMenu = popoversMenu else { return }
        if popoversMenu.isPresented {
            popoversMenu.dismiss()
        } else {
            popoversMenu.present()
        }
    }
    
    func setupDismissButton() {
        if model.addDismissButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
        }
    }

    @objc func optionsPressed() {}
    
    @objc func dismissSelf() {
        dismiss(animated: true)
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
