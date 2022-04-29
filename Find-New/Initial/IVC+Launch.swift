//
//  IVC+Launch.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension InitialViewController {
    // MARK: - Onboarding

    func loadOnboarding() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

        let launchViewController = LaunchViewController.make(model: launchViewModel)

        launchViewController.aboutToEnter = { [weak self] in
            guard let self = self else { return }
            self.loadApp()
        }

        launchViewController.entering = { [weak self] in
            guard let self = self else { return }
            self.onboardingEntering()
        }

        launchViewController.done = { [weak self] in
            guard let self = self else { return }
            self.onboardingDone()
        }

        self.launchViewController = launchViewController
        addChildViewController(launchViewController, in: view)
        view.bringSubviewToFront(launchViewController.view)
    }

    func onboardingEntering() {
        viewController?.view.transform = .init(scaleX: 1.4, y: 1.4)
        UIView.animate(duration: 0.6, dampingFraction: 1) {
            self.viewController?.view.transform = .identity
        }
    }

    func onboardingDone() {
        guard let launchViewController = launchViewController else { return }
        if !realmModel.launchedBefore, !realmModel.addedListsBefore {
            realmModel.addSampleLists()
        }

        realmModel.entered()
        AppDelegate.AppUtility.lockOrientation(.all)
        removeChildViewController(launchViewController)
        self.launchViewController = nil
        startApp()
    }
}
