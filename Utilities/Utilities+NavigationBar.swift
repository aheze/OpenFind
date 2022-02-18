//
//  Utilities+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension UIBarButtonItem {
    static func customButton(customView: UIView, length: CGFloat = 28) -> UIBarButtonItem {
        let menuBarItem = UIBarButtonItem(customView: customView)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: length).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: length).isActive = true

        return menuBarItem
    }

    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        return customButton(customView: button)
    }
}
