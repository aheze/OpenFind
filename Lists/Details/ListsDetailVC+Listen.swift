//
//  ListsDetailVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension ListsDetailViewController {
    func listenToButtons() {
        
        /// change icon
        headerTopLeftView.tapped = { [weak self] in
            guard let self = self else { return }
            
        }
        
        /// change color
        headerTopRightView.tapped = { [weak self] in
            guard let self = self else { return }
            
        }
        
        /// edit mode
        wordsTopLeftView.tapped = { [weak self] in
            guard let self = self else { return }
            self.model.isEditing.toggle()
            self.model.isEditingChanged?()
        }
        
        /// add word
        headerTopRightView.tapped = { [weak self] in
            guard let self = self else { return }
            
        }
    }
    
    func listenToModel() {
        model.isEditingChanged = { [weak self] in
            guard let self = self else { return }
            
            if self.model.isEditing {
                self.wordsTopLeftLabel.text = "Done"
                self.toolbarViewModel.toolbar = AnyView(self.toolbarView)
            } else {
                self.wordsTopLeftLabel.text = "Edit"
                self.toolbarViewModel.toolbar = nil
                self.model.selectedIndices = []
            }
            
            for index in self.model.list.words.indices {
                guard let cell = self.wordsTableView.cellForRow(at: index.indexPath) as? ListsDetailWordCell else { continue }
                
                if self.model.isEditing {
                    cell.stackViewLeftC.constant = 0
                    cell.stackViewRightC.constant = 0
                    UIView.animate(withDuration: ListsDetailConstants.editAnimationDuration) {
                        cell.leftView.isHidden = false
                        cell.rightView.isHidden = false
                        cell.stackView.layoutIfNeeded()
                    }
                } else {
                    cell.stackViewLeftC.constant = ListsDetailConstants.listRowContentEdgeInsets.left
                    cell.stackViewRightC.constant = ListsDetailConstants.listRowContentEdgeInsets.right
                    UIView.animate(withDuration: ListsDetailConstants.editAnimationDuration) {
                        cell.leftView.isHidden = true
                        cell.rightView.isHidden = true
                        cell.stackView.layoutIfNeeded()
                    } completion: { _ in
                        cell.leftSelectionIconView.setState(.empty)
                    }
                }
            }
        }
    }
}
