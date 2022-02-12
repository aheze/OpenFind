//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    let realmModel = RealmModel()
    let photosViewModel = PhotosViewModel()
    let cameraViewModel = CameraViewModel()
    let listsViewModel = ListsViewModel()
    let toolbarViewModel = ToolbarViewModel()

    lazy var photos = PhotosController(model: photosViewModel, toolbarViewModel: toolbarViewModel, realmModel: realmModel)
    lazy var camera = CameraController(model: cameraViewModel, realmModel: realmModel)
    lazy var lists = ListsController(model: listsViewModel, toolbarViewModel: toolbarViewModel, realmModel: realmModel)


    lazy var tabController: TabBarController = {
        photos.viewController.toolbarViewModel = toolbarViewModel

        let tabController = TabBarController(
            pages: [photos.viewController, camera.viewController, lists.searchNavigationController],
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )

        tabController.delegate = self

        self.addChildViewController(tabController.viewController, in: self.view)
        updateExcludedFrames()
        return tabController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = tabController

        realmModel.loadLists()
        lists.viewController.reload()

        setup()
        updateExcludedFrames()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.updateExcludedFrames()
        }
    }
}

public extension UIView {
    /// Convert a view's frame to global coordinates, which are needed for `sourceFrame` and `excludedFrames.`
    func windowFrame() -> CGRect {
        return convert(bounds, to: nil)
    }
}

public extension Optional where Wrapped: UIView {
    /// Convert a view's frame to global coordinates, which are needed for `sourceFrame` and `excludedFrames.` This is a convenience overload for optional `UIView`s.
    func windowFrame() -> CGRect {
        if let view = self {
            return view.windowFrame()
        }
        return .zero
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
