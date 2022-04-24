//
//  SettingsMVC+Keyboard.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsMainViewController {
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height - Global.safeAreaInsets.bottom

            UIView.animate(withDuration: 0.5) {
                self.scrollView.contentInset.bottom = keyboardHeight
                self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            }
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}
