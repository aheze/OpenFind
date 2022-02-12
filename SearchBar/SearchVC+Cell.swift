//
//  SearchVC+Cell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/29/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
    func getCell(for index: Int) -> UICollectionViewCell {
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: index.indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        
        configureCell(cell, for: index)
        return cell
    }

    func configureCell(_ cell: SearchFieldCell, for index: Int) {
        /// the field, currently. Won't update even if it changes, so must compare id later.
        let field = searchViewModel.fields[index]
        let text = field.value.getText()
        cell.textField.text = text
        cell.textField.inputAccessoryView = toolbarViewController.view
        setClearIcon(for: cell, text: text, valuesCount: searchViewModel.values.count)
        
        cell.configuration = searchViewModel.configuration
        cell.setConfiguration()
        
        setFieldValue(for: cell, field: field)
        
        cell.textChanged = { [weak self] text in
            guard let self = self else { return }
            
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            self.searchViewModel.fields[index].value = .word(
                .init(
                    string: text,
                    color: Constants.defaultHighlightColor.getFieldColor(for: index).hex
                )
            )
            self.updateClearIcons(valuesCount: self.searchViewModel.values.count)
            self.setFieldValue(for: cell, field: self.searchViewModel.fields[index])
        }
        
        
        cell.leftViewTapped = { [weak self] in
            guard let self = self else { return }
            
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            self.presentPopover(for: index, from: cell)
        }
        cell.rightViewTapped = { [weak self] in
            guard let self = self else { return }
            
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            let value = self.searchViewModel.fields[index].value
            if value.getText().isEmpty {
                self.removeCell(at: index)
            } else {
                cell.textField.text = ""
                self.searchViewModel.fields[index].value = .word(
                    .init(
                        string: "",
                        color: Constants.defaultHighlightColor.getFieldColor(for: index).hex
                    )
                )
                self.setClearIcon(for: cell, text: "", valuesCount: self.searchViewModel.values.count)
            }
            
            cell.textField.becomeFirstResponder()
        }
        
        if let focusedIndex = searchViewModel.collectionViewModel.focusedCellIndex, focusedIndex == index {
            cell.activate(true)
        } else {
            cell.activate(false)
        }
        
        cell.entireViewTapped = { [weak self] in
            guard let self = self else { return }
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            
            if let origin = self.searchCollectionViewFlowLayout.layoutAttributes[safe: index]?.fullOrigin {
                let targetOrigin = self.searchCollectionViewFlowLayout.getTargetOffsetForScrollingThere(for: CGPoint(x: origin, y: 0), velocity: .zero)
                self.searchCollectionView.setContentOffset(targetOrigin, animated: true)
            }
            if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                cell.textField.becomeFirstResponder()
            }
        }
    }
    
    /// `valuesCount` = `searchViewModel.values.count` usually. But if deleting, subtract 1.
    func updateClearIcons(valuesCount: Int) {
        let values = searchViewModel.values
        
        for index in values.indices {
            let field = searchViewModel.fields[index]
            if let cell = searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                setClearIcon(for: cell, text: field.value.getText(), valuesCount: valuesCount)
            }
        }
    }
    
    func setClearIcon(for cell: SearchFieldCell, text: String, valuesCount: Int) {
        if text.isEmpty {
            if valuesCount >= 2 {
                cell.rightView.clearIconView.setState(.delete, animated: true)
            } else {
                cell.rightView.clearIconView.setState(.hidden, animated: true)
            }
        } else {
            cell.rightView.clearIconView.setState(.clear, animated: true)
        }
    }
    
    func setFieldValue(for cell: SearchFieldCell, field: Field) {
        switch field.value {
        case .word:
            cell.loadConfiguration(showAddNew: false)
            cell.leftView.imageView.alpha = 0
            cell.leftView.findIconView.alpha = 1
            cell.leftView.findIconView.setTint(
                color: field.overrides.selectedColor ?? UIColor(hex: field.value.getColor()),
                alpha: field.overrides.alpha
            )
            cell.leftViewRightC.constant = searchViewModel.configuration.fieldExtraPadding
        case .list(let list):
            cell.loadConfiguration(showAddNew: false)
            cell.leftView.imageView.alpha = 1
            cell.leftView.findIconView.alpha = 0
            cell.leftView.imageView.image = UIImage(systemName: list.icon)
            cell.leftView.imageView.tintColor = UIColor(hex: list.color)
            cell.leftViewRightC.constant = searchViewModel.configuration.fieldExtraPaddingList
        case .addNew:
            cell.loadConfiguration(showAddNew: true)
            cell.leftView.imageView.alpha = 0
            cell.leftView.findIconView.alpha = 1
            cell.leftView.findIconView.setTint(
                color: field.overrides.selectedColor ?? UIColor(hex: field.value.getColor()),
                alpha: field.overrides.alpha
            )
            cell.leftViewRightC.constant = searchViewModel.configuration.fieldExtraPadding
        }
    }
    
    func removeCell(at index: Int) {
        /// Make sure there are are least 2 fields
        guard searchViewModel.values.count >= 2 else { return }
        
        if index == searchViewModel.values.count - 1 {
            let targetIndex = index - 1
            searchViewModel.collectionViewModel.deletedIndex = index
            searchViewModel.collectionViewModel.fallbackIndex = targetIndex
            searchViewModel.collectionViewModel.focusedCellIndex = nil /// prevent target offset
            searchCollectionView.isUserInteractionEnabled = false
            updateClearIcons(valuesCount: searchViewModel.values.count - 1)
            UIView.animate(withDuration: 0.4) {
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            if let cell = searchCollectionView.cellForItem(at: targetIndex.indexPath) as? SearchFieldCell {
                cell.activate(true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let origin = self.searchCollectionViewFlowLayout.layoutAttributes[safe: targetIndex]?.fullOrigin { /// the last field that's not the "add new" field
                    self.searchViewModel.collectionViewModel.highlightingAddWordField = false
                    let (targetOrigin, focusedIndex) = self.searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
                    self.searchCollectionView.setContentOffset(targetOrigin, animated: true) /// go to that offset instantly
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.searchViewModel.collectionViewModel.deletedIndex = nil
                        self.searchViewModel.collectionViewModel.fallbackIndex = nil
                        self.searchViewModel.fields.remove(at: index)
                        self.searchCollectionView.deleteItems(at: [index.indexPath])
                        self.searchCollectionView.isUserInteractionEnabled = true
                        self.searchViewModel.collectionViewModel.reachedEndBeforeAddWordField = true
                        
                        if let cell = self.searchCollectionView.cellForItem(at: targetIndex.indexPath) as? SearchFieldCell {
                            cell.textField.becomeFirstResponder()
                        }
                        
                        self.searchViewModel.collectionViewModel.focusedCellIndex = focusedIndex
                    }
                }
            }
        } else {
            searchViewModel.collectionViewModel.deletedIndex = index
            searchViewModel.collectionViewModel.fallbackIndex = nil
            searchViewModel.collectionViewModel.focusedCellIndex = nil /// prevent target offset
            searchCollectionView.isUserInteractionEnabled = false
            updateClearIcons(valuesCount: searchViewModel.values.count - 1)
            UIView.animate(withDuration: 0.4) {
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchViewModel.collectionViewModel.deletedIndex = nil
                self.searchViewModel.collectionViewModel.fallbackIndex = nil
                self.searchViewModel.fields.remove(at: index)
                self.searchCollectionView.deleteItems(at: [index.indexPath])
                self.searchCollectionView.isUserInteractionEnabled = true
                self.searchViewModel.collectionViewModel.focusedCellIndex = index
                
                /// If the focused index is the second to last, make `reachedEndBeforeAddWordField` true
                if index == self.searchViewModel.values.count - 1 {
                    self.searchViewModel.collectionViewModel.reachedEndBeforeAddWordField = true
                }
                
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.activate(true)
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }
}
