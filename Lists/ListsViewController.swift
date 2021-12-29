//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, PageViewController {
    var tabType: TabState = .lists
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ListsViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {}
}
