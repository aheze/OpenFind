//
//  CameraVC+Keyboard.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    @objc func _KeyboardFrameChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            var shouldFade = false
            if didFinishShouldUpdateHeight {
                self.toolbarTopC?.update(offset: rect.origin.y - 80)
                if rect.width == CGFloat(0) {
                    shouldFade = true
                }
            }
            if rect.width != CGFloat(0) {
                self.toolbarWidthC?.update(offset: rect.width)
                self.toolbarLeftC?.update(offset: rect.origin.x)
            }
            UIView.animate(withDuration: 0.6, animations: {
                if rect.width < screenBounds.size.width {
                    self.toolbar.layer.cornerRadius = 5
                } else {
                    self.toolbar.layer.cornerRadius = 0
                }
                if shouldFade == true {
                    self.toolbar.alpha = 0
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc func _KeyboardHeightChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.5, animations: {
                let rect = frame.cgRectValue
                if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                    if let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                        if rect.width == CGFloat(0) {
                            self.didFinishShouldUpdateHeight = true
                        } else {
                            self.didFinishShouldUpdateHeight = false
                            self.toolbarTopC?.update(offset: rect.origin.y - 80)
                            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                                if rect.origin.y == screenBounds.size.height {
                                    self.toolbar.alpha = 0
                                } else {
                                    self.toolbar.alpha = 1
                                }
                                self.view.layoutIfNeeded()
                            }, completion: nil)
                        }
                    }
                }
            })
        }
    }
}
