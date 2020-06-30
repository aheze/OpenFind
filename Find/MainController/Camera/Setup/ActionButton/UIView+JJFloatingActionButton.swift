//
//  UIView+JJFloatingActionButton.swift
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

internal extension UIView {
    class func animate(duration: TimeInterval,
                       delay: TimeInterval = 0,
                       usingSpringWithDamping dampingRatio: CGFloat,
                       initialSpringVelocity velocity: CGFloat,
                       options: UIView.AnimationOptions = [.beginFromCurrentState],
                       animations: @escaping () -> Void,
                       completion: ((Bool) -> Void)? = nil,
                       group: DispatchGroup? = nil,
                       animated: Bool = true) {
        let groupedAnimations: () -> Void = {
            group?.enter()
            animations()
        }
        let groupedCompletion: (Bool) -> Void = { finished in
            completion?(finished)
            group?.leave()
        }

        if animated {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           usingSpringWithDamping: dampingRatio,
                           initialSpringVelocity: velocity,
                           options: options,
                           animations: groupedAnimations,
                           completion: groupedCompletion)
        } else {
            groupedAnimations()
            groupedCompletion(true)
        }
    }

    class func transition(with view: UIView,
                          duration: TimeInterval,
                          options: UIView.AnimationOptions = [.transitionCrossDissolve],
                          animations: (() -> Swift.Void)?,
                          completion: ((Bool) -> Swift.Void)? = nil,
                          group: DispatchGroup? = nil,
                          animated: Bool = true) {
        let groupedAnimations: () -> Void = {
            group?.enter()
            animations?()
        }

        let groupedCompletion: (Bool) -> Void = { finished in
            completion?(finished)
            group?.leave()
        }

        if animated {
            UIView.transition(with: view,
                              duration: duration,
                              options: options,
                              animations: groupedAnimations,
                              completion: groupedCompletion)
        } else {
            groupedAnimations()
            groupedCompletion(true)
        }
    }
}
