//
//  ListsVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func makeFlowLayout() -> ListsCollectionFlowLayout {
        let flowLayout = ListsCollectionFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.getSections = { [weak self] in
            guard let self = self else { return [] }
            let section = Section(
                items: Array(
                    repeating: Section.Item.placeholder,
                    count: self.model.displayedLists.count
                )
            )
            return [section]
        }
        flowLayout.getSizeForIndexWithWidth = { [weak self] listIndex, availableWidth in
            guard let self = self else { return .zero }
            return self.writeCellFrameAndReturnSize(index: listIndex, availableWidth: availableWidth)
        }

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }

    /// write chip frames and return the size
    func writeCellFrameAndReturnSize(index: Int, availableWidth: CGFloat) -> CGSize {
        let list = model.displayedLists[index].list

        let (cellSize, chipFrames) = list.getContentViewSize(availableWidth: availableWidth)
        model.displayedLists[index].frame.chipFrames = chipFrames
        return cellSize
    }
}
