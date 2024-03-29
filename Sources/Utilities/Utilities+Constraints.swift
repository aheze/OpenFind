//
//  Utilities+Constraints.swift
//  Find
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CGRect {
    func setAsConstraints(left: NSLayoutConstraint, top: NSLayoutConstraint, width: NSLayoutConstraint, height: NSLayoutConstraint) {
        left.constant = origin.x.isFinite ? origin.x : 0
        top.constant = origin.y.isFinite ? origin.y : 0
        width.constant = size.width.isFinite ? size.width : 0
        height.constant = size.height.isFinite ? size.height : 0
    }
}

extension UIView {
    func pinEdgesToSuperview(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: padding.top),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -padding.right),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: padding.left)
        ])
    }

    func pinEdgesToSuperviewAndReturnTopConstraint() -> NSLayoutConstraint? {
        guard let superview = superview else { return nil }
        self.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = self.topAnchor.constraint(equalTo: superview.topAnchor)
        NSLayoutConstraint.activate([
            topConstraint,
            self.rightAnchor.constraint(equalTo: superview.rightAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor)
        ])

        return topConstraint
    }
}
