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
        tabViewModel.willBeginNavigatingTo = { [weak self] tabState in
            guard let self = self else { return }
            self.willBeginNavigatingTo(tab: tabState)
        }

        tabViewModel.didFinishNavigatingTo = { [weak self] tabState in
            guard let self = self else { return }
            self.didFinishNavigatingTo(tab: tabState)
        }
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
