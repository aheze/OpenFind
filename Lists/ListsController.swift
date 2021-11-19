//
//  ListsController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public class ListsController {
    public var viewController: ListsViewController
    
    init() {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as! ListsViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
