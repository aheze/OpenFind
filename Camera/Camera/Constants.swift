//
//  Constants.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct Constants {
    static var activeIconColor = UIColor(hex: 0x8AF9FF)
    static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
