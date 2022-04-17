//
//  VC+Tabs.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ViewController {
    func setupTabs() {
        tabViewModel.willBeginNavigating = { [weak self] oldTabState, newTabState in
            guard let self = self else { return }
            self.willBeginNavigating(from: oldTabState, to: newTabState)
        }

        tabViewModel.didFinishNavigating = { [weak self] oldTabState, newTabState in
            guard let self = self else { return }
            self.didFinishNavigating(from: oldTabState, to: newTabState)
        }
    }
}

extension ViewController {
    func willBeginNavigating(from oldTabState: TabState, to newTabState: TabState) {
        view.endEditing(true)
        
        switch newTabState {
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

    func didFinishNavigating(from oldTabState: TabState, to newTabState: TabState) {
        switch newTabState {
        case .photos:
            photos.viewController.didBecomeActive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeInactive()

            tabViewModel.statusBarStyle = .default
        case .camera:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeActive()
            lists.searchNavigationController.didBecomeInactive()

            tabViewModel.statusBarStyle = .lightContent
        case .lists:
            photos.viewController.didBecomeInactive()
            camera.viewController.didBecomeInactive()
            lists.searchNavigationController.didBecomeActive()

            tabViewModel.statusBarStyle = .default
        default: break
        }

        tabViewModel.statusBarStyleChanged?()
    }
}
