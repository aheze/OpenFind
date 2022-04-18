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
            self.view.endEditing(true)
            self.presentIconPicker()
        }
        
        /// change color
        headerTopRightView.tapped = { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.presentColorPicker()
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
                self.configureCellSelection(cell, animate: true)
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
    }
}
