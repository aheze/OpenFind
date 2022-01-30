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
                    cell.headerSelectionIconView.alpha = 0
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.headerSelectionIconView.isHidden = false
                        cell.headerStackView.layoutIfNeeded()
                        cell.headerSelectionIconView.alpha = 1
                    }
                } else {
                    cell.headerSelectionIconView.alpha = 1
                    UIView.animate(withDuration: ListsCellConstants.editAnimationDuration) {
                        cell.headerSelectionIconView.isHidden = true
                        cell.headerStackView.layoutIfNeeded()
                        cell.headerSelectionIconView.alpha = 0
                    } completion: { _ in
                        cell.headerSelectionIconView.setState(.empty)
                    }
                }
                
                
            }
        }
    }
}
