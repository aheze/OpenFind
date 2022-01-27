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
            
            if #available(iOS 15.0, *) {
                if let presentationController = self.iconPicker.searchNavigationController.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium(), .large()]
                }
            }
            self.present(self.iconPicker.searchNavigationController, animated: true)
            self.headerTopLeftIconPickerModel.selectedIcon = self.model.list.image
            self.headerTopLeftIconPickerModel.iconChanged = { [weak self] icon in
                self?.model.list.image = icon
            }
        }
        
        /// change color
        headerTopRightView.tapped = { [weak self] in
            guard let self = self else { return }
            if #available(iOS 14.0, *) {
                let colorPicker = UIColorPickerViewController()
                
                if #available(iOS 15.0, *) {
                    if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.medium(), .large()]
                    }
                }
                
                self.present(colorPicker, animated: true)
            } else {
                
                let colorPicker = ColorPickerNavigationViewController(model: self.headerTopRightColorPickerModel)
                self.present(colorPicker, animated: true)
            }
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
                self.model.selectedIndices = []
                self.wordsTableView.isEditing = false
            }
            
            for index in self.model.editableWords.indices {
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
            
            let selectedIndices = self.model.selectedIndices
            let indexPaths = selectedIndices.map { IndexPath(item: $0, section: 0) }
            
            for index in selectedIndices.sorted(by: >) {
                self.model.editableWords.remove(at: index)
            }
            
            self.model.selectedIndices = []
            self.wordsTableView.deleteRows(at: indexPaths, with: .automatic)
            
            if self.model.editableWords.count == 0 {
                self.addWord()
            }
            
            self.updateTableViewHeightConstraint()
        }
    }
}
