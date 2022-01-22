//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class ViewController: UIViewController {
    let cameraViewModel = CameraViewModel()
    let listsViewModel = ListsViewModel()
    
    lazy var photos: PhotosController = PhotosBridge.makeController()

    lazy var camera: CameraController = CameraBridge.makeController(
        cameraViewModel: cameraViewModel,
        listsViewModel:listsViewModel
    )

    lazy var lists: ListsController = ListsBridge.makeController(listsViewModel: listsViewModel)
    
    var toolbarViewModel: ToolbarViewModel!
    lazy var tabController: TabBarController<PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
        toolbarViewModel = ToolbarViewModel()
        
        photos.viewController.getActiveToolbarViewModel = { [weak self] in
            self?.toolbarViewModel ?? ToolbarViewModel()
        }
        photos.viewController.activateSelectionToolbar = { [weak self] activate, animate in
            guard let self = self else { return }
            if activate {
                if animate {
                    withAnimation {
                        self.toolbarViewModel.toolbar = .photosSelection
                    }
                } else {
                    self.toolbarViewModel.toolbar = .photosSelection
                }
            } else {
                if animate {
                    withAnimation {
                        self.toolbarViewModel.toolbar = .none
                    }
                } else {
                    self.toolbarViewModel.toolbar = .none
                }
            }
        }
        
        _ = lists
        let tabController = TabControllerBridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.searchNavigationController],
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel,
            photosSelectionToolbarView: photos.viewController.selectionToolbar,
            photosDetailToolbarView: photos.viewController.selectionToolbar,
            listsSelectionToolbarView: photos.viewController.selectionToolbar
        )
        
        tabController.delegate = self
        
        self.addChildViewController(tabController.viewController, in: self.view)

        let searchBar = camera.viewController.searchViewController.searchBarView ?? UIView()
        let searchBarBounds = searchBar.convert(searchBar.bounds, to: nil)
        tabController.viewController.excludedFrames = [searchBarBounds]
        return tabController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = tabController
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: nil)
        let searchContainerFrame = camera.viewController.searchContainerView.convert(camera.viewController.searchContainerView.bounds, to: nil)

        if searchContainerFrame.contains(location) {
            return false
        }
        
        return true
    }
}

extension ViewController: TabBarControllerDelegate {
    func willBeginNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.willBecomeActive()
            camera.viewController.willBecomeInactive()
            lists.searchNavigationController.willBecomeInactive()
        case .camera:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeActive()
            lists.searchNavigationController.willBecomeInactive()
        case .lists:
            photos.viewController.willBecomeInactive()
            camera.viewController.willBecomeInactive()
            lists.searchNavigationController.willBecomeActive()
        default: break
        }
    }
    
    func didFinishNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photos.viewController.didBecomeActive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeInactive()
        case .camera:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeActive()
            lists.searchNavigationController.didBecomeInactive()
        case .lists:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeActive()
        default: break
        }
    }
}
