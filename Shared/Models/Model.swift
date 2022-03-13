//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Models for the search bar. Includes color.
 */

enum Value {
    case word(Word)
    case list(List)
}

struct Gradient {
    var colors = [UIColor]()
    var alpha = CGFloat(1)
}
