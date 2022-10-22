//
//  ListsDetailVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 Contains the Scroll View and Text Field delegates.
 */

/// Scroll view
extension ListsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset
        updateSearchBarOffset?()
    }
}

extension ListsDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if
            let text = textField.text,
            let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if textField == headerTopCenterTextField {
                model.list.title = updatedText
            } else if textField == headerBottomTextField {
                model.list.description = updatedText
            }
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
