//
//  ListsDetailVC+Scroll.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func focusCell(at index: Int) {
        if model.list.words.indices.contains(index) {
            if let cell = wordsTableView.cellForRow(at: index.indexPath) as? ListsDetailWordCell {
                cell.textField.becomeFirstResponder()
            }
        }
    }

    func scrollToCell(at index: Int) {
        let currentOffset = scrollView.contentOffset

        if model.list.words.indices.contains(index) {
            if let cell = wordsTableView.cellForRow(at: index.indexPath) as? ListsDetailWordCell {
                /// origin of cell, relative to the words table view
                let cellOrigin = cell.convert(cell.bounds.origin, to: contentView).y
                
                /// need a slightly more negative offset to center the cell
                let cellOriginWhenCentered = cellOrigin + cell.bounds.height / 2
                
                let topBarHeight = baseSearchBarOffset
                
                let keyboardHeight = model.keyboardHeight
                
                /// visible area
                let safeAreaHeight = view.bounds.height - topBarHeight - keyboardHeight
                
                /// midpoint in the safe area
                let targetOriginRelativeToScreen = topBarHeight + safeAreaHeight / 2
                
                let targetContentOffset = cellOriginWhenCentered - targetOriginRelativeToScreen
                
                /// The scroll view's content offset will also be -91 when it is at the top (scroll edge appearance)
                /// Prevent setting offset to greater than -91
                let clampedOffset = max(targetContentOffset, -topBarHeight)
                
                scrollView.setContentOffset(CGPoint(x: 0, y: clampedOffset), animated: true)
                
                if model.contentOffsetAddition == nil {
                    /// subtract this later when keyboard hides.
                    model.contentOffsetAddition = clampedOffset - currentOffset.y
                }
            }
        }
    }
}

class ListsDetailScrollView: UIScrollView {
    override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {}
}
