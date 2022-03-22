//
//  Utilities+UIView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let contains = subviews.contains {
            !$0.isHidden
            && $0.isUserInteractionEnabled
            && $0.point(inside: self.convert(point, to: $0), with: event)
        }

        return contains
    }
}

extension UIView {
    func centerInParent() {
        guard let superview = superview else { return }
        self.center = CGPoint(
            x: superview.bounds.width / 2,
            y: superview.bounds.height / 2
        )
    }
}

extension UIView {
    static func animate(
        duration: CGFloat,
        dampingFraction: CGFloat,
        animations: @escaping (() -> Void),
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: dampingFraction,
            initialSpringVelocity: 1,
            animations: animations
        ) { _ in
            completion?()
        }
    }
}
