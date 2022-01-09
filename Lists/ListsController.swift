//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsController {
    var listsViewModel: ListsViewModel
    var navigationController: UINavigationController
    var viewController: ListsViewController
    
    init(listsViewModel: ListsViewModel) {
        self.listsViewModel = listsViewModel
        
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ListsViewController") { coder in
            ListsViewController(
                coder: coder,
                listsViewModel: listsViewModel
            )
        }
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    
        let navigationController = UINavigationController(rootViewController: viewController)
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    
        viewController.setupNavigationBar()
    }
}
