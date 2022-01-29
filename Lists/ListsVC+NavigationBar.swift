//
//  ListsViewController+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController {
    func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addListPressed)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    @objc func addListPressed() {
        addNewList()
    }
}
