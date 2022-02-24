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
        cell.model = searchViewModel
        
        /// the field, currently. Won't update even if it changes, so must compare id later.
        let field = searchViewModel.fields[index]
        let text = field.value.getText()
        
        if case .addNew = field.value {
            cell.configureAddNew(isAddNew: true)
        } else {
            cell.configureAddNew(isAddNew: false)
        }
        
        cell.textField.text = text
        cell.textField.inputAccessoryView = toolbarViewController.view
        setClearIcon(for: cell, text: text, valuesCount: searchViewModel.values.count)
        
        cell.setConfiguration()
        
        configure(cell, for: field)
        
        cell.textChanged = { [weak self] text in
            guard let self = self else { return }
            
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            
            self.searchViewModel.setFieldValue(at: index) {
                .word(
                    .init(
                        string: text,
                        color: Constants.defaultHighlightColor.getFieldColor(for: index).hex
                    )
                )
            }
            self.updateClearIcons(valuesCount: self.searchViewModel.values.count)
            self.configure(cell, for: self.searchViewModel.fields[index])
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
                self.searchViewModel.setFieldValue(at: index) {
                    .word(
                        .init(
                            string: "",
                            color: Constants.defaultHighlightColor.getFieldColor(for: index).hex
                        )
                    )
                }
                self.setClearIcon(for: cell, text: "", valuesCount: self.searchViewModel.values.count)
                self.configure(cell, for: self.searchViewModel.fields[index])
            }
            
            cell.textField.becomeFirstResponder()
        }
        
        if let focusedIndex = collectionViewModel.focusedCellIndex, focusedIndex == index {
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
    
    /// set the cell's left icon
    func configure(_ cell: SearchFieldCell, for field: Field) {
        switch field.value {
        case .word:
            cell.leftView.imageView.alpha = 0
            cell.leftView.findIconView.alpha = 1
            cell.leftView.findIconView.setTint(
                color: field.overrides.selectedColor ?? UIColor(hex: field.value.getColor()),
                alpha: field.overrides.alpha
            )
            cell.updateBackgroundColor()
        case .list(let list):
            cell.leftView.imageView.alpha = 1
            cell.leftView.findIconView.alpha = 0
            cell.leftView.imageView.image = UIImage(systemName: list.icon)
            cell.leftView.imageView.tintColor = UIColor.white.toColor(field.overrides.selectedColor ?? UIColor(hex: list.color), percentage: field.overrides.alpha)
            cell.updateBackgroundColor()
        case .addNew:
            cell.leftView.imageView.alpha = 0
            cell.leftView.findIconView.alpha = 1
            cell.leftView.findIconView.setTint(
                color: field.overrides.selectedColor ?? UIColor(hex: field.value.getColor()),
                alpha: field.overrides.alpha
            )
            cell.updateBackgroundColor()
        }
    }
    
    func removeCell(at index: Int) {
        /// Make sure there are are least 2 fields
        guard searchViewModel.values.count >= 2 else { return }
        
        if index == searchViewModel.values.count - 1 {
            let targetIndex = index - 1
            collectionViewModel.deletedIndex = index
            collectionViewModel.fallbackIndex = targetIndex
            collectionViewModel.focusedCellIndex = nil /// prevent target offset
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
                    self.collectionViewModel.highlightingAddWordField = false
                    let (targetOrigin, focusedIndex) = self.searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
                    self.searchCollectionView.setContentOffset(targetOrigin, animated: true) /// go to that offset instantly
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.collectionViewModel.deletedIndex = nil
                        self.collectionViewModel.fallbackIndex = nil
                        self.searchViewModel.fields.remove(at: index)
                        self.searchCollectionView.deleteItems(at: [index.indexPath])
                        self.searchCollectionView.isUserInteractionEnabled = true
                        self.collectionViewModel.reachedEndBeforeAddWordField = true
                        
                        if let cell = self.searchCollectionView.cellForItem(at: targetIndex.indexPath) as? SearchFieldCell {
                            cell.textField.becomeFirstResponder()
                        }
                        
                        self.collectionViewModel.focusedCellIndex = focusedIndex
                    }
                }
            }
        } else {
            collectionViewModel.deletedIndex = index
            collectionViewModel.fallbackIndex = nil
            collectionViewModel.focusedCellIndex = nil /// prevent target offset
            searchCollectionView.isUserInteractionEnabled = false
            updateClearIcons(valuesCount: searchViewModel.values.count - 1)
            UIView.animate(withDuration: 0.4) {
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionViewModel.deletedIndex = nil
                self.collectionViewModel.fallbackIndex = nil
                self.searchViewModel.fields.remove(at: index)
                self.searchCollectionView.deleteItems(at: [index.indexPath])
                self.searchCollectionView.isUserInteractionEnabled = true
                self.collectionViewModel.focusedCellIndex = index
                
                /// If the focused index is the second to last, make `reachedEndBeforeAddWordField` true
                if index == self.searchViewModel.values.count - 1 {
                    self.collectionViewModel.reachedEndBeforeAddWordField = true
                }
                
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.activate(true)
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }
}
