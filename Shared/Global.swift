//
//  Global.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

/**
 Global vars
 */
enum Global {
    static var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }
}
