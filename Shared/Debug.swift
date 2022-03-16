//
//  Debug.swift
//  Find
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum Debug {
    
    /// Everything should be false on release
    static var tabBarAlwaysTransparent = false
    static var navigationBarAlwaysTransparent = true
    static var collectionViewScrollDisabled = false
}

extension UIView {
    
    /// add a border to a view
    func addDebugBorders(_ color: UIColor, width: CGFloat = 0.5) {
        backgroundColor = color.withAlphaComponent(0.3)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
