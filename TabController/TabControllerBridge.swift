//
//  TabControllerBridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import SwiftUI

struct TabControllerBridge {
    static func makeTabController(
        pageViewControllers: [PageViewController],
        cameraViewModel: CameraViewModel,
        toolbarViewModel: ToolbarViewModel
    ) -> TabBarController {
        let tabBarController = TabBarController(
            pages: pageViewControllers,
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel
        )
        
        return tabBarController
    }
}
