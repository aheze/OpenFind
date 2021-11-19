//
//  ViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 10/28/21.
//

import SwiftUI
import TabBarController
import Photos
import Camera
import Lists

class ViewController: UIViewController {

    lazy var photos: PhotosController = {
        return Photos.Bridge.makeController()
    }()
    lazy var camera: CameraController = {
        return Camera.Bridge.makeController()
    }()
    lazy var lists: ListsController = {
        return Lists.Bridge.makeController()
    }()
    
    var toolbarViewModel: ToolbarViewModel!
    lazy var tabController: TabBarController<Camera.CameraToolbarView, Photos.PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
        toolbarViewModel = ToolbarViewModel()
        
        
        photos.viewController.activateSelectionToolbar = { [weak self] activate in
            guard let self = self else { return }
            if activate {
                withAnimation {
                    self.toolbarViewModel.toolbar = .photosSelection
                }
            } else {
                withAnimation {
                    self.toolbarViewModel.toolbar = .none
                }
            }
        }
        
        let tabController = Bridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.viewController],
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: camera.viewController.toolbar,
            photosSelectionToolbarView: photos.viewController.selectionToolbar,
            photosDetailToolbarView: photos.viewController.selectionToolbar,
            listsSelectionToolbarView: photos.viewController.selectionToolbar
        )
        
        tabController.delegate = self
        
        self.addChild(tabController.viewController, in: self.view)
        
        return tabController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = tabController
       
    }
}

extension ViewController: TabBarControllerDelegate {
    func willBeginNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.willBecomeActive()
            camera.viewController.willBecomeInactive()
            lists.viewController.willBecomeInactive()
        case .camera:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeActive()
            lists.viewController.willBecomeInactive()
        case .lists:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeInactive()
            lists.viewController.willBecomeActive()
        default: break
        }
    }
    
    func didFinishNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.didBecomeActive()
            camera.viewController.didBecomeInactive()
            lists.viewController.didBecomeInactive()
        case .camera:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeActive()
            lists.viewController.didBecomeInactive()
        case .lists:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeInactive()
            lists.viewController.didBecomeActive()
        default: break
        }
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

