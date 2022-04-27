//
//  Utilities+CGRect.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import UIKit

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }

    func scaleTo(_ size: CGSize) -> CGRect {
        var rect = CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.width * size.width,
            height: self.height * size.height
        )
        rect = rect.insetBy(dx: -3, dy: -3)

        return rect
    }
}

extension CGRect {
    init(center: CGPoint, length: CGFloat) {
        let origin = CGPoint(
            x: center.x - length / 2,
            y: center.y - length / 2
        )

        let size = CGSize(width: length, height: length)
        self.init(origin: origin, size: size)
    }
}

extension CGRect {
    /// round for printing
    func rounded(toPlaces: Int = 3) -> CGRect {
        return CGRect(
            x: origin.x.rounded(toPlaces: toPlaces),
            y: origin.y.rounded(toPlaces: toPlaces),
            width: width.rounded(toPlaces: toPlaces),
            height: height.rounded(toPlaces: toPlaces)
        )
    }
}
