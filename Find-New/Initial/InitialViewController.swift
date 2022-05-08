//
//  InitialViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

struct InitialProperties {
    var viewControllerLoaded = false
    var listToLoad: List?
    var migratedPhotoMetadatas = [PhotoMetadata]()
    var migratedLists = [List]()
}

class InitialViewController: UIViewController {
    var realmModel = RealmModel()
    var properties = InitialProperties()
    var viewController: ViewController?

    /// lazy load everything
    lazy var launchViewModel = LaunchViewModel()
    var launchViewController: LaunchViewController?

    /// this gets called before `viewDidLoad`, so check `loaded` first
    override var childForStatusBarHidden: UIViewController? {
        if properties.viewControllerLoaded {
            return viewController?.tabController.viewController
        } else {
            return nil
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        if properties.viewControllerLoaded {
            return viewController?.tabController.viewController
        } else {
            return nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureRealm()

        if realmModel.launchedBefore || Debug.overrideLaunch {
            loadApp()
            startApp()
        } else {
            if UIAccessibility.isVoiceOverRunning {
                realmModel.entered()
            } else {
                loadOnboarding()
            }
        }
    }

    // MARK: - Start App

    func loadApp() {
        realmModel.started()

        properties.viewControllerLoaded = true

        /// start the app up
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ViewController") { coder in
            ViewController(coder: coder, realmModel: self.realmModel)
        }
        self.viewController = viewController
        addChildViewController(viewController, in: view)
        print("added!")
    }

    /// once the app is started, perform any additional steps
    func startApp() {
        importListIfNeeded()
    }
}
