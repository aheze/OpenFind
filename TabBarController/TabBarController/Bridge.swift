//
//  Bridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//


import SwiftUI

public struct Bridge {
    public static func makeTabViewController<ToolbarView: View>(pageViewControllers: [PageViewController], toolbarView: ToolbarView) -> TabBarController<ToolbarView> {
        
        let toolbarController = TabBarController(pages: pageViewControllers, toolbarView: toolbarView)
//        let bundle = Bundle(identifier: "com.aheze.TabBarController")
//        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController<ToolbarView>
//        viewController.pages = pageViewControllers
//        viewController.toolbarView = toolbarView
        return toolbarController
    }
}
