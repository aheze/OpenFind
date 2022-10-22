//
//  ViewController.swift
//  TabController
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    let cameraViewModel = CameraViewModel()
    let model = ListsViewModel()
    var toolbarViewModel = ToolbarViewModel()

    lazy var photos: PhotosController = PhotosBridge.makeController()

    lazy var camera: CameraController = CameraBridge.makeController(
        cameraViewModel: cameraViewModel,
        model: model
    )

    lazy var lists: ListsController = ListsBridge.makeController(model: model)

    lazy var tabController: TabBarController = {
        toolbarViewModel = ToolbarViewModel()

        let tabController = TabControllerBridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.searchNavigationController],
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )

        tabController.delegate = self

        self.addChildViewController(tabController.viewController, in: self.view)

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

extension ViewController {
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
