//
//  PopoverController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import Combine

class PopoverController {
    var popoverModel: PopoverModel
    var windowScene: UIWindowScene
    
    lazy var newWindow: UIWindow = {
        let window = UIWindow(windowScene: windowScene)
        return window
    }()
    
    lazy var popoverContainerViewController: PopoverContainerViewController = {
        let popoverContainerViewController = PopoverContainerViewController(popoverModel: popoverModel)
        return popoverContainerViewController
    }()
    
    init(popoverModel: PopoverModel, windowScene: UIWindowScene) {
        self.popoverModel = popoverModel
        self.windowScene = windowScene
        _ = popoverContainerViewController
        
        newWindow.rootViewController = popoverContainerViewController
        newWindow.windowLevel = .alert
        newWindow.backgroundColor = .clear
        newWindow.makeKeyAndVisible()
        
    }
    func present() {
        
    }
}


