//
//  CameraVC+Testing.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension CameraViewController {
    func addTestingTabBar(add: Bool) {
        if add {
            let tabBarHostingController = UIHostingController(
                rootView: TabBarView(
                    tabViewModel: TabViewModel(),
                    toolbarViewModel: ToolbarViewModel(),
                    cameraViewModel: cameraViewModel
                )
            )
            
            tabBarHostingController.view.backgroundColor = .clear
            testingTabBarContainerView.backgroundColor = .clear
            addChildViewController(tabBarHostingController, in: testingTabBarContainerView)
            testingTabBarContainerView.isHidden = false
            testingTabBarContainerView.addDebugBorders(.blue)
        } else {
            testingTabBarContainerView.isHidden = true
        }
    }
}
