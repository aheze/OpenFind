//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchContainerView: UIView!
    
    var searchViewModel = SearchViewModel()
    var listsViewModel = ListsViewModel()
    
    lazy var searchViewController: SearchViewController = {
        searchViewModel.availableLists = listsViewModel.lists
//        searchViewModel.fields = []
        print("fiels;: \(searchViewModel.fields)")
        let viewController = Bridge.makeViewController(searchViewModel: searchViewModel)
        self.addChild(viewController, in: self.searchContainerView)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        _ = searchViewController
        
        
    }
    
}

