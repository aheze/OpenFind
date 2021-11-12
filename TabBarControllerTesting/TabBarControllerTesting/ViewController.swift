//
//  ViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 10/28/21.
//

import UIKit
import TabBarController

class ToolbarViewModel: ObservableObject {
    @Published var toolbar = Toolbar.camera(Camera())
    
    enum Toolbar {
        case camera(Camera)
        case photosSelection(PhotosSelection)
        case photosDetail(PhotosDetail)
        case listsSelection(ListsSelection)
    }
    
    class Camera: ObservableObject {
        @Published var resultsCount = 0
        @Published var flashOn = false
        @Published var focusOn = false
    }

    class PhotosSelection: ObservableObject {
        @Published var starOn = false
    }
    class PhotosDetail: ObservableObject {
        @Published var starOn = false
    }
    class ListsSelection: ObservableObject {
        @Published var selectedCount = 0
    }
}

class ViewController: UIViewController {

    var toolbarViewModel: ToolbarViewModel!
    lazy var tabBarViewController: TabBarController<ToolbarViewModel, CameraToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
        toolbarViewModel = ToolbarViewModel()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let photosViewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController,
            let cameraViewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController,
            let listsViewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ListsViewController
        else { fatalError("No view controllers!") }
        
        let tabViewController = Bridge.makeTabViewController(
            pageViewControllers: [photosViewController, cameraViewController, listsViewController],
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: cameraViewController.toolbar,
            photosSelectionToolbarView: photosViewController.selectionToolbar,
            photosDetailToolbarView: photosViewController.selectionToolbar,
            listsSelectionToolbarView: photosViewController.selectionToolbar
        )
        
        self.addChild(tabViewController.viewController, in: self.view)
        
        return tabViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = tabBarViewController
       
    }
}
class ListsViewController: UIViewController, PageViewController {
    var tabType: TabState = .lists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lists loaded")
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

