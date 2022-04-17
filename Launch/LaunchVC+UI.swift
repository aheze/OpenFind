//
//  LaunchVC+UI.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension LaunchViewController {
    func setupUI() {
        setupView()
        prepareUI()
    }

    func setupView() {
        let contentView = LaunchView(model: model)
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: contentContainer)
    }

    func prepareUI() {
        if Debug.skipLaunchIntro {
            model.showingUI = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.showUIDelay) {
                withAnimation(.easeInOut(duration: LaunchConstants.showUIDuration)) {
                    self.model.showingUI = true
                }
            }
        }
    }
}
