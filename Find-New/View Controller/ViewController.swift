//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    var realmModel: RealmModel

    lazy var photosPermissionsViewModel = PhotosPermissionsViewModel()
    lazy var tabViewModel = TabViewModel()
    lazy var photosViewModel = PhotosViewModel()
    lazy var cameraViewModel = CameraViewModel()
    lazy var listsViewModel = ListsViewModel()
    lazy var toolbarViewModel = ToolbarViewModel()

    lazy var settingsController = SettingsController(realmModel: realmModel)
    lazy var photos = PhotosController(
        model: photosViewModel,
        realmModel: realmModel,
        tabViewModel: tabViewModel,
        photosPermissionsViewModel: photosPermissionsViewModel,
        toolbarViewModel: toolbarViewModel
    )
    lazy var camera = CameraController(
        model: cameraViewModel,
        tabViewModel: tabViewModel,
        photosPermissionsViewModel: photosPermissionsViewModel,
        realmModel: realmModel
    )
    lazy var lists = ListsController(
        model: listsViewModel,
        tabViewModel: tabViewModel,
        toolbarViewModel: toolbarViewModel,
        realmModel: realmModel
    )

    /// loading this in `viewDidLoad` will cascade and load everything else
    lazy var tabController: TabBarController = {
        let tabController = TabBarController(
            pages: [
                photos.searchNavigationController,
                camera.viewController,
                lists.searchNavigationController
            ],
            model: tabViewModel,
            realmModel: realmModel,
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )

        self.addChildViewController(tabController.viewController, in: self.view)
        return tabController
    }()

    init?(coder: NSCoder, realmModel: RealmModel) {
        self.realmModel = realmModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        listen()
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
