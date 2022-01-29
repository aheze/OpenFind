//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var searchContainerView: UIView!
    
    var searchViewModel = SearchViewModel()
    
    lazy var searchViewController: SearchViewController = {
        let viewController = Bridge.makeViewController(
            searchViewModel: searchViewModel,
            configuration: .photos
        )
        self.addResizableChildViewController(viewController, in: self.searchContainerView)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .secondarySystemBackground
        _ = searchViewController
    }
}
