//
//  ListsDetailVC+Keyboard.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
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
            model.keyboardHeight = keyboardHeight
            bottomSpacerHeightC.constant = keyboardHeight
            
            if keyboardHeight <= Constants.minimumKeyboardHeight {
                wordsKeyboardToolbarViewModel.keyboardShown = false
                reloadWordsToolbarFrame(keyboardShown: false)
                return
            }
        }
        wordsKeyboardToolbarViewModel.keyboardShown = true
        reloadWordsToolbarFrame(keyboardShown: true)
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        
        let currentOffset = scrollView.contentOffset
        bottomSpacerHeightC.constant = 0
        
        view.layoutIfNeeded()
        scrollView.setContentOffset(currentOffset, animated: false)
        
        if let contentOffsetAddition = model.contentOffsetAddition {
            model.contentOffsetAddition = nil
            let newOffset = CGPoint(x: 0, y: currentOffset.y - contentOffsetAddition)
            scrollView.setContentOffset(newOffset, animated: true)
        }
        
        wordsKeyboardToolbarViewModel.keyboardShown = false
        reloadWordsToolbarFrame(keyboardShown: false)
    }
}
