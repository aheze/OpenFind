//
//  Global.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Global vars. Make sure to configure `window`
 */
enum Global {
    static var window: UIWindow?
    static var safeAreaInsets: UIEdgeInsets {
        return window?.safeAreaInsets ?? .zero
    }
}
