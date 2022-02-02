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
            self?.presentIconPicker()
        }
        
        /// change color
        headerTopRightView.tapped = { [weak self] in
            self?.presentColorPicker()
        }
        
        /// edit mode
        wordsTopLeftView.tapped = { [weak self] in
            guard let self = self else { return }
            self.model.isEditing.toggle()
            self.model.isEditingChanged?()
        }
        
        /// add word
        wordsTopRightView.tapped = { [weak self] in
            guard let self = self else { return }
            self.addWord()
            self.updateTableViewHeightConstraint()
        }
    }
    
    func listenToModel() {
        model.isEditingChanged = { [weak self] in
            guard let self = self else { return }
            
            if self.model.isEditing {
                self.wordsTopLeftLabel.text = "Done"
                self.toolbarViewModel.toolbar = AnyView(self.toolbarView)
                self.wordsTableView.isEditing = true
            } else {
                self.wordsTopLeftLabel.text = "Edit"
                self.toolbarViewModel.toolbar = nil
                self.model.selectedWords = []
                self.wordsTableView.isEditing = false
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
        
        model.deleteSelected = { [weak self] in
            guard let self = self else { return }
            
            var selectedIndices = [Int]()
            for word in self.model.selectedWords {
                if let index = self.model.list.words.firstIndex(where: { $0.id == word.id }) {
                    selectedIndices.append(index)
                }
            }
            let indexPaths = selectedIndices.map { IndexPath(item: $0, section: 0) }
            
            for index in selectedIndices.sorted(by: >) {
                self.model.list.words.remove(at: index)
            }
            
            self.model.selectedWords = []
            self.wordsTableView.deleteRows(at: indexPaths, with: .automatic)
            
            if self.model.list.words.count == 0 {
                self.addWord()
            }
            
            self.updateTableViewHeightConstraint()
        }
        
        /// toolbar
        wordsKeyboardToolbarViewModel.goToIndex = { [weak self] index in
            guard let self = self else { return }
            self.focusCell(at: index)
            self.scrollToCell(at: index)
        }
        
        wordsKeyboardToolbarViewModel.addWordAfterIndex = { [weak self] index in
            guard let self = self else { return }
            let newIndex = index + 1
            self.addWord(at: newIndex)
            self.focusCell(at: newIndex)
            self.updateTableViewHeightConstraint()
        }
    }
}
