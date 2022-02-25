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
                let cellOrigin = cell.convert(cell.bounds.origin, to: wordsTableView)

                /// origin of table view in the scroll view
                let wordsTableViewOrigin = wordsTableView.convert(wordsTableView.bounds.origin, to: contentView)

                let wordsHeaderHeight = wordsTopView.bounds.height

                let navigationBarHeight = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets) + detailsSearchViewModel.getTotalHeight()
                let topPadding: CGFloat
                if traitCollection.verticalSizeClass == .compact {
                    topPadding = ListsDetailConstants.focusedCellTopPaddingCompactHeight
                } else {
                    topPadding = (view.bounds.height - navigationBarHeight - model.keyboardHeight) / 2
                }

                /// relative to `contentView`
                let relativeCellOrigin = cellOrigin.y + wordsTableViewOrigin.y + wordsHeaderHeight
                let additionalPadding = navigationBarHeight + topPadding

                let offset = relativeCellOrigin - additionalPadding

                /// Usually 151. The scroll view's content offset will also be 151 when it is at the top.
                let baseOffset = baseSearchBarOffset + detailsSearchViewModel.getTotalHeight()

                /// Prevent setting offset to greater than -151 (drag down rubber band after hitting top)
                let clampedOffset = max(offset, -baseOffset)

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
