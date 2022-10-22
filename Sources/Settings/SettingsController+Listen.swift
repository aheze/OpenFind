//
//  SettingsController+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension SettingsController {
    func listen() {
        model.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchController.updateSearchBarOffset()
        }
        model.show = { [weak self] page in
            guard let self = self else { return }
            let scrollViewController = SettingsScrollViewController(
                model: self.model,
                realmModel: self.realmModel,
                searchViewModel: self.searchViewModel,
                page: page
            )
            self.searchController.navigation.pushViewController(scrollViewController, animated: true)
        }
        
        model.showRows = { [weak self] path in
            guard let self = self else { return }
            
            var viewControllers = [SettingsScrollViewController]()
            for row in path {
                if case .link(title: _, leftIcon: _, indicatorStyle: _, destination: let destination, action: let action) = row.configuration {
                    if let destination = destination {
                        let scrollViewController = SettingsScrollViewController(
                            model: self.model,
                            realmModel: self.realmModel,
                            searchViewModel: self.searchViewModel,
                            page: destination
                        )
                        viewControllers.append(scrollViewController)
                        
                        /// external link
                    } else if let action = action {
                        action()
                        return
                    }
                }
            }
            
            self.searchController.navigation.pushViewControllers(viewControllers, animated: true)
        }
    }
}


extension UINavigationController {
    
    /// https://stackoverflow.com/a/50991286/14351818
    func pushViewControllers(_ inViewControllers: [UIViewController], animated: Bool) {
        var stack = self.viewControllers
        stack.append(contentsOf: inViewControllers)
        self.setViewControllers(stack, animated: animated)
    }
}
