//
//  SearchVC+Keyboard.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
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
            let keyboardHeight = keyboardRectangle.height

            if keyboardHeight <= Constants.minimumKeyboardHeight {
                collectionViewModel.keyboardShown = false
                reloadToolbarFrame()
                return
            }
        }
        collectionViewModel.keyboardShown = true
        reloadToolbarFrame()
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        collectionViewModel.keyboardShown = false
        reloadToolbarFrame()
    }
}
