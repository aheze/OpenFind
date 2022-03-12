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
        left.constant = origin.x
        top.constant = origin.y
        width.constant = size.width
        height.constant = size.height
    }
}

extension UIView {
    func pinEdgesToSuperview() {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor)
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
