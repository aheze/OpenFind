//
//  HighlightColor.swift
//  Find
//
//  Created by Zheng on 3/29/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct HighlightColor: Equatable {
    var cgColor: CGColor
    var hexString: String
    
    static func == (lhs: HighlightColor, rhs: HighlightColor) -> Bool {
        return lhs.cgColor == rhs.cgColor
    }
}
