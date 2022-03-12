//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    var loaded = false

    /// lazy load everything
    lazy var tabViewModel = TabViewModel()
    lazy var realmModel = RealmModel()
    lazy var photosViewModel = PhotosViewModel(realmModel: realmModel)
    lazy var cameraViewModel = CameraViewModel()
    lazy var listsViewModel = ListsViewModel()
    lazy var toolbarViewModel = ToolbarViewModel()

    lazy var photos = PhotosController(model: photosViewModel, tabViewModel: tabViewModel, toolbarViewModel: toolbarViewModel)
    lazy var camera = CameraController(model: cameraViewModel, tabViewModel: tabViewModel, realmModel: realmModel)
    lazy var lists = ListsController(model: listsViewModel, tabViewModel: tabViewModel, toolbarViewModel: toolbarViewModel, realmModel: realmModel)

    /// loading this in `viewDidLoad` will cascade and load everything else
    lazy var tabController: TabBarController = {
        photos.viewController.toolbarViewModel = toolbarViewModel

        let tabController = TabBarController(
            pages: [photos.searchNavigationController, camera.viewController, lists.searchNavigationController],
            model: tabViewModel,
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )

        self.addChildViewController(tabController.viewController, in: self.view)
        updateExcludedFrames()
        return tabController
    }()

    /// this gets called before `viewDidLoad`, so check `loaded` first
    override var childForStatusBarHidden: UIViewController? {
        if loaded {
            return tabController.viewController
        } else {
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loaded = true

        /// start the app up
        _ = tabController

        setup()
        realmModel.loadLists()
        lists.viewController.reload()
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
