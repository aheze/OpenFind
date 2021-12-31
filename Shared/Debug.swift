//
//  Debug.swift
//  Find
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// Everything should be false on release
enum Debug {
    static var tabBarAlwaysTransparent = false
}

extension UIView {
    func addDebugBorders(_ color: UIColor, width: CGFloat = 0.5) {
        backgroundColor = color.withAlphaComponent(0.3)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
