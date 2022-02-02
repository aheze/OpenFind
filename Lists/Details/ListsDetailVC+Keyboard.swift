//
//  ListsDetailVC+Keyboard.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func focusCell(at index: Int) {
        if model.list.words.indices.contains(index) {
            if let cell = wordsTableView.cellForRow(at: index.indexPath) as? ListsDetailWordCell {
                cell.textField.becomeFirstResponder()

                /// origin of cell, relative to the words table view
                let cellOrigin = cell.convert(cell.bounds.origin, to: wordsTableView)

                /// origin of table view in the scroll view
                let wordsTableViewOrigin = wordsTableView.convert(wordsTableView.bounds.origin, to: contentView)

                let wordsHeaderHeight = wordsTopView.bounds.height

                let navigationBarHeight = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets) + searchViewModel.getTotalHeight()
                let topPadding: CGFloat
                if traitCollection.verticalSizeClass == .compact {
                    topPadding = ListsDetailConstants.focusedCellTopPaddingCompactHeight
                } else {
                    topPadding = (view.bounds.height - navigationBarHeight - scrollView.contentInset.bottom) / 2
                }

                /// relative to `contentView`
                let relativeCellOrigin = cellOrigin.y + wordsTableViewOrigin.y + wordsHeaderHeight
                let additionalPadding = navigationBarHeight + topPadding

                let offset = relativeCellOrigin - additionalPadding

                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }

    func listenToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            scrollView.contentInset.bottom = keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
}

class ListsDetailScrollView: UIScrollView {
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {}
}
