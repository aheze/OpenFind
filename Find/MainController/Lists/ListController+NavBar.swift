//
//  ListController+NavBar.swift
//  Find
//
//  Created by Zheng on 12/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ListController {
    func setUpBarButtons() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addPressed(sender:)))
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPressed(sender:)))
        navigationItem.rightBarButtonItems = [addButton, selectButton]
    }
    @objc func addPressed(sender: UIBarButtonItem) {
        print("add")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ListBuilderViewController") as? ListBuilderViewController {
            viewController.listBuilderType = .maker
            viewController.newListDelegate = self
            viewController.iconColorName = randomizedColor
            self.present(viewController, animated: true, completion: nil)
        }
    }
    @objc func selectPressed(sender: UIBarButtonItem) {
        print("select")
    }
    
    
}
