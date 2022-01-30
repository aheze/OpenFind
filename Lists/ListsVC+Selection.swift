//
//  ListsVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension ListsViewController {
    func toggleSelect() {
        listsViewModel.isSelecting.toggle()
        
        if listsViewModel.isSelecting {
            selectBarButton.title = "Done"
            toolbarViewModel.toolbar = AnyView(toolbarView)
            
        } else {
            selectBarButton.title = "Select"
            toolbarViewModel.toolbar = nil
            listsViewModel.selectedLists = []
        }
        
        for index in listsViewModel.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                if listsViewModel.isSelecting {
                    cell.headerImageView.alpha = 0
                    cell.headerSelectionIconView.alpha = 1
                } else {
                    cell.headerImageView.alpha = 1
                    cell.headerSelectionIconView.alpha = 0
                    cell.headerSelectionIconView.setState(.empty)
                }
            }
        }
    }
}
