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
    
    lazy var searchViewController: SearchViewController = {
        
        let viewController = Bridge.viewController()
        self.addChild(viewController, in: self.searchContainerView)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        _ = searchViewController
        
    }
    
}

