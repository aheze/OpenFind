//
//  PhotosVC+NavBar.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func setupBarButtons() {
        
        let photos = NSLocalizedString("welcomeToPhotos", comment: "")
        self.title = photos
        
        
        let findText = NSLocalizedString("universal-find", comment: "")
        let selectText = NSLocalizedString("universal-select", comment: "")
        
        findButton = UIBarButtonItem(title: findText, style: .plain, target: self, action: #selector(findPressed(sender:)))
        selectButton = UIBarButtonItem(title: selectText, style: .plain, target: self, action: #selector(selectPressed(sender:)))
        
        findButton.tintColor = UIColor(named: "PhotosText")
        selectButton.tintColor = UIColor(named: "PhotosText")
        
        navigationItem.rightBarButtonItems = [findButton, selectButton]
        
        findButton.isEnabled = false
        selectButton.isEnabled = false
    }
    @objc func findPressed(sender: UIBarButtonItem) {
        findPressed()
    }
    @objc func selectPressed(sender: UIBarButtonItem) {
        selectPressed()
    }
}
