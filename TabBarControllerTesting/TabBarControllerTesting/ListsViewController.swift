//
//  ListsViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/13/21.
//

import UIKit
import TabBarController

class ListsViewController: UIViewController, PageViewController {
    
    var tabType: TabState = .lists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lists loaded")
    }
}

extension ListsViewController {
    
    func willBecomeActive() {
        
    }
    
    func didBecomeActive() {
        
    }
    
    func willBecomeInactive() {
        
    }
    
    func didBecomeInactive() {
        
    }
}
