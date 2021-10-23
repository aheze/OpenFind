//
//  ViewController.swift
//  SearchBarTesting
//
//  Created by Zheng on 10/14/21.
//

import UIKit
import SearchBar

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


