//
//  TabBarController.swift
//  TabBarController
//
//  Created by Zheng on 11/10/21.
//

import Combine
import SwiftUI

class TabBarController: NSObject {
    /// data
    var viewController: TabBarViewController
    
    /// model
    var model: TabViewModel
    var realmModel: RealmModel
    var cameraViewModel: CameraViewModel
    var toolbarViewModel: ToolbarViewModel
    
    init(
        pages: [PageViewController],
        model: TabViewModel,
        realmModel: RealmModel,
        cameraViewModel: CameraViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        // MARK: - init first

        self.model = model
        self.realmModel = realmModel
        self.cameraViewModel = cameraViewModel
        self.toolbarViewModel = toolbarViewModel
        
        let storyboard = UIStoryboard(name: "TabContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "TabBarViewController") { coder in
            TabBarViewController(
                coder: coder,
                pages: pages,
                model: model,
                realmModel: realmModel
            )
        }
        
        print("make")
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        
        super.init()

        // MARK: - setup
        
        /// make the tab bar the height of the camera
        viewController.updateTabBarHeight(.camera)
        
        let tabBarHostingController = UIHostingController(
            rootView: TabBarView(
                tabViewModel: model,
                toolbarViewModel: toolbarViewModel,
                cameraViewModel: cameraViewModel
            )
        )
        
        tabBarHostingController.view.backgroundColor = .clear
        viewController.tabBarContainerView.backgroundColor = .clear
        viewController.addChildViewController(tabBarHostingController, in: viewController.tabBarContainerView)

    }
}
