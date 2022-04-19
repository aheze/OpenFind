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
    var listToLoad: List?

    var realmModel = RealmModel()
    
    /// lazy load everything
    lazy var launchViewModel = LaunchViewModel()
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
        toolbarViewModel: toolbarViewModel
    )
    lazy var camera = CameraController(
        model: cameraViewModel,
        tabViewModel: tabViewModel,
        realmModel: realmModel
    )
    lazy var lists = ListsController(
        model: listsViewModel,
        tabViewModel: tabViewModel,
        toolbarViewModel: toolbarViewModel,
        realmModel: realmModel
    )

    lazy var launchViewController = LaunchViewController.make(model: launchViewModel) { [weak self] in
        guard let self = self else { return }
        self.onboardingEntering()
    } done: { [weak self] in
        guard let self = self else { return }
        self.onboardingDone()
    }

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

    override var childForStatusBarStyle: UIViewController? {
        if loaded {
            return tabController.viewController
        } else {
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading!!!")
        print("view loaded.: \(realmModel)")
//        loadMigratedData()
        
        if !RealmContainer.migratedPhotoMetadatas.isEmpty || !RealmContainer.migratedLists.isEmpty {
            print("loading!!")
            loadMigratedData(
                migratedPhotoMetadatas: RealmContainer.migratedPhotoMetadatas,
                migratedLists: RealmContainer.migratedLists
            )
        }
        
        loadApp()

        if realmModel.launchedBefore || Debug.overrideLaunch {
            startApp()
        } else {
            loadOnboarding()
        }
    }
    
    // MARK: - Migration
    func loadMigratedData(migratedPhotoMetadatas: [PhotoMetadata], migratedLists: [List]) {
        print("migrate calleda!!")
//        _ = realmModel
        
        print("realmModel made!! \(realmModel)")
        
        for metadata in migratedPhotoMetadatas {
            print("adding!! \(metadata.assetIdentifier).. \(metadata.isStarred)")
            realmModel.container.updatePhotoMetadata(metadata: metadata)
        }
        
        for list in migratedLists {
            print("adding!! \(list.title)")
            realmModel.container.addList(list: list)
        }
    }

    // MARK: - Onboarding

    func loadOnboarding() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

        _ = launchViewController
        addChildViewController(launchViewController, in: view)
        view.bringSubviewToFront(launchViewController.view)
    }

    func onboardingEntering() {
        self.tabController.viewController.view.transform = .init(scaleX: 1.4, y: 1.4)
        UIView.animate(duration: 0.6, dampingFraction: 1) {
            self.tabController.viewController.view.transform = .identity
        }
    }

    func onboardingDone() {
        AppDelegate.AppUtility.lockOrientation(.all)
        removeChildViewController(launchViewController)
        startApp()
    }

    // MARK: - Start App

    func loadApp() {
        loaded = true

        /// start the app up
        _ = tabController

        setup()
        listen()
        updateExcludedFrames()
    }

    func startApp() {
        importListIfNeeded()
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
