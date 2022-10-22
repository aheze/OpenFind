//
//  Utilities+Accessibility.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension View {
    /// accessibility label
    func accessibilityLabel(_ string: String) -> some View {
        accessibility(label: Text(string))
    }

    func accessibilityValue(_ string: String) -> some View {
        accessibility(value: Text(string))
    }

    func accessibilityHint(_ string: String) -> some View {
        accessibility(hint: Text(string))
    }
}

extension UIColor {
    var readableDescription: String {
        if #available(iOS 14.0, *) {
            return self.accessibilityName
        } else {
            return "#\(self.hexString)"
        }
    }
}
