//
//  JJFloatingActionButton+Placement.swift
//
//  Copyright (c) 2017-Present Jochen Pfeiffer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

@objc public extension JJFloatingActionButton {
    /// Add floating action button to a given superview and place in trailing bottom corner.
    ///
    /// - Parameter superview: The view to which the floating action button is added as a subview.
    /// - Parameter bottomInset: The (minimum) bottom vertical spacing in points between button and superview.
    ///             Default is `16`.
    /// - Parameter trailingInset: The (minimum) trailing horizontal spacing in points between button and superview.
    ///             Default is `16`.
    /// - Parameter safeAreaInset: The (minimum) spacing in points between button and safe area of the superview.
    ///             Default is `0`.
    ///
    /// - Remark: On iOS prior to iOS 11 `safeAreaInset` is ignored.
    ///
    func display(inView superview: UIView,
                 bottomInset: CGFloat = 16,
                 trailingInset: CGFloat = 16,
                 safeAreaInset: CGFloat = 0) {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        var trailing: NSLayoutConstraint

        trailing = trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailingInset)
        trailing.priority = UILayoutPriority(250)
        trailing.isActive = true

        trailing = trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -trailingInset)
        trailing.priority = .required
        trailing.isActive = true

        if #available(iOS 11.0, *) {
            trailing = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -safeAreaInset)
            trailing.priority = UILayoutPriority(750)
            trailing.isActive = true

            trailing = trailingAnchor.constraint(lessThanOrEqualTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -safeAreaInset)
            trailing.priority = .required
            trailing.isActive = true
        }

        var bottom: NSLayoutConstraint

        bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottomInset)
        bottom.priority = UILayoutPriority(250)
        bottom.isActive = true

        bottom = bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor, constant: -bottomInset)
        bottom.priority = .required
        bottom.isActive = true

        if #available(iOS 11.0, *) {
            bottom = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -safeAreaInset)
            bottom.priority = UILayoutPriority(750)
            bottom.isActive = true

            bottom = bottomAnchor.constraint(lessThanOrEqualTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -safeAreaInset)
            bottom.priority = .required
            bottom.isActive = true
        }
    }

    /// Add floating action button to a view of a given view controller and place in trailing bottom corner.
    ///
    /// - Parameter viewController: The view controller to which view the floating action button is added as a subview.
    /// - Parameter bottomInset: The (minimum) bottom vertical spacing in points between button and superview.
    ///             Default is `16`.
    /// - Parameter trailingInset: The (minimum) trailing horizontal spacing in points between button and superview.
    ///             Default is `16`.
    /// - Parameter safeAreaInset: The (minimum) spacing in points between button and safe area of the view controllers view.
    ///             Default is `0`.
    ///
    /// - Remark: On iOS prior to iOS 11 `safeAreaInset` is ignored.
    ///
    func display(inViewController viewController: UIViewController,
                 bottomInset: CGFloat = 16,
                 trailingInset: CGFloat = 16,
                 safeAreaInset: CGFloat = 0) {
        if let superview = viewController.view {
            display(inView: superview, bottomInset: bottomInset, trailingInset: trailingInset, safeAreaInset: safeAreaInset)
            var bottom: NSLayoutConstraint

            bottom = bottomAnchor.constraint(equalTo: viewController.bottomLayoutGuide.topAnchor, constant: -bottomInset)
            bottom.priority = UILayoutPriority(500)
            bottom.isActive = true

            bottom = bottomAnchor.constraint(lessThanOrEqualTo: viewController.bottomLayoutGuide.topAnchor, constant: -bottomInset)
            bottom.priority = .required
            bottom.isActive = true
        }
    }
}
