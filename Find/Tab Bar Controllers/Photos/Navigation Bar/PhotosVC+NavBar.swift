//
//  PhotosVC+NavBar.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func setUpBarButtons() {
        self.title = "Photos"
        findButton = UIBarButtonItem(title: "Find", style: .plain, target: self, action: #selector(findPressed(sender:)))
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPressed(sender:)))
        
        navigationItem.rightBarButtonItems = [findButton, selectButton]
    }
    @objc func findPressed(sender: UIBarButtonItem) {
        print("Find")
        findPressed()
    }
    @objc func selectPressed(sender: UIBarButtonItem) {
        selectPressed()
        print("select")
    }
}
