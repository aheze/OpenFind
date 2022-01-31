//
//  SearchTextField.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {
    var sideInset = CGFloat(10)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let safeBounds = bounds.insetBy(dx: sideInset, dy: 0)

        if safeBounds.contains(point) {
            return super.point(inside: point, with: event)
        } else {
            return false
        }
    }
}
