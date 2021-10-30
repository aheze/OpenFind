//
//  ViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 10/28/21.
//

import UIKit
import TabBarController

class ViewController: UIViewController {

    lazy var tabBarViewController: TabBarViewController = {
        
        let viewController = Bridge.viewController()
        self.addChild(viewController, in: self.view)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = tabBarViewController
        
    }
}

extension UIViewController {
    func addChild(_ childViewController: UIViewController, in inView: UIView) {
        // Add Child View Controller
        addChild(childViewController)
        
        // Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        // Configure Child View
        childViewController.view.frame = inView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    func removeChild(_ childViewController: UIViewController) {
        // Notify Child View Controller
        childViewController.willMove(toParent: nil)

        // Remove Child View From Superview
        childViewController.view.removeFromSuperview()

        // Notify Child View Controller
        childViewController.removeFromParent()
    }
}

