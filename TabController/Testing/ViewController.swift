//
//  ViewController.swift
//  TabController
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    var cameraToolbarModel = CameraViewModel()
    
    lazy var photos: PhotosController = PhotosBridge.makeController()

    lazy var camera: CameraController = CameraBridge.makeController(model: cameraToolbarModel)

    lazy var lists: ListsController = ListsBridge.makeController()
    
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
        
        let tabController = TabControllerBridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.viewController],
            cameraViewModel: cameraToolbarModel,
            toolbarViewModel: toolbarViewModel,
            photosSelectionToolbarView: photos.viewController.selectionToolbar,
            photosDetailToolbarView: photos.viewController.selectionToolbar,
            listsSelectionToolbarView: photos.viewController.selectionToolbar
        )
        
        tabController.delegate = self
        
        self.addChild(tabController.viewController, in: self.view)
        
//        tabController.viewController.contentCollectionView
//            .panGestureRecognizer
        ////            .shouldRequireFailure(of:
//            .require(toFail:
        ////            .shouldBeRequiredToFail(by:
        ////            .shouldRequireFailure(
        ////                of:
        camera.viewController.searchViewController.searchCollectionView.panGestureRecognizer
//            )
//        tabController.viewController.contentCollectionView.panGestureRecognizer.shouldReceive(<#T##event: UIEvent##UIEvent#>)
//        camera.viewController.searchViewController.searchCollectionView.panGestureRecognizer.delegate = self
        
//        camera.viewController.searchViewController.searchCollectionView.addGestureRecognizer(UIPanGestureRecognizer())
//        camera.viewController.searchViewController.searchCollectionView.panGestureRecognizer.shouldBeRequiredToFail(by: tabController.viewController.contentCollectionView.panGestureRecognizer)
//            .delegate = self
        
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
