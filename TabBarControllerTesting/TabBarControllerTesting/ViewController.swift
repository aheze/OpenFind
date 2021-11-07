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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let photosViewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController,
            let cameraViewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController,
            let listsViewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ListsViewController
        else { fatalError("No view controllers!") }
        
        let tabViewController = Bridge.tabViewController([photosViewController, cameraViewController, listsViewController])
        self.addChild(tabViewController, in: self.view)
        
        return tabViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = tabBarViewController
        
       
    }
}

class PhotosViewController: UIViewController, PageViewController {
    var tabType: TabState = .photos
}
class CameraViewController: UIViewController, PageViewController {
    var tabType: TabState = .camera
}
class ListsViewController: UIViewController, PageViewController {
    var tabType: TabState = .lists
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

