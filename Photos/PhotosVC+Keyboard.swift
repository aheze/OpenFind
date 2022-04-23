//
//  PhotosVC+Keyboard.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
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
            let keyboardHeight = keyboardRectangle.height - tabViewModel.tabBarAttributes.backgroundHeight

            UIView.animate(withDuration: 0.5) {
                self.resultsCollectionView.contentInset.bottom = keyboardHeight
                self.resultsCollectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight
                self.collectionView.contentInset.bottom = keyboardHeight
                self.collectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            }
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            let bottomHeight = PhotosConstants.bottomPadding + SliderConstants.height /// padding for the slider
            self.resultsCollectionView.contentInset.bottom = bottomHeight
            self.resultsCollectionView.verticalScrollIndicatorInsets.bottom = bottomHeight
            self.collectionView.contentInset.bottom = bottomHeight
            self.collectionView.verticalScrollIndicatorInsets.bottom = bottomHeight
        }
    }
}
