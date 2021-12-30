//
//  SearchVC+Cell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/29/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import UIKit

extension SearchViewController {
    func configureCell(for index: Int) -> UICollectionViewCell {
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: index.indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        
        let field = searchViewModel.fields[index]
        let text = field.value.getText()
        
        cell.textField.text = text
        setClearIcon(for: cell, text: text, valuesCount: searchViewModel.values.count)
        
        switch field.value {
        case .string:
            cell.loadConfiguration(showAddNew: false)
        case .list:
            cell.loadConfiguration(showAddNew: false)
        case .addNew:
            cell.loadConfiguration(showAddNew: true)
        }
        
        cell.textChanged = { [weak self] text in
            guard let self = self else { return }
            
            /// update the index
            let index = self.searchViewModel.fields.firstIndex { $0.id == field.id } ?? 0
            
            self.searchViewModel.fields[index].value = .string(text)
            self.updateClearIcons(valuesCount: self.searchViewModel.values.count)
            
        }
        cell.leftView.findIconView.setTint(
            color: field.attributes.selectedColor ?? field.attributes.defaultColor,
            alpha: field.attributes.alpha
        )
        
        
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
                self.searchViewModel.fields[index].value = .string("")
                self.setClearIcon(for: cell, text: "", valuesCount: self.searchViewModel.values.count)
            }
            
            cell.textField.becomeFirstResponder()
        }
        
        if let focusedIndex = searchCollectionViewFlowLayout.focusedCellIndex, focusedIndex == index {
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
        
        return cell
    }
    
    /// `valuesCount` = `searchViewModel.values.count` usually. But if deleting, subtract 1.
    func updateClearIcons(valuesCount: Int) {
        let values = self.searchViewModel.values
        
        for index in values.indices {
            let field = searchViewModel.fields[index]
            if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
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
    
    func removeCell(at index: Int) {
        
        /// Make sure there are are least 2 fields
        guard searchViewModel.values.count >= 2 else { return }
        
        if index == self.searchViewModel.values.count - 1 {
            let targetIndex = index - 1
            searchCollectionViewFlowLayout.deletedIndex = index
            searchCollectionViewFlowLayout.fallbackIndex = targetIndex
            searchCollectionView.isUserInteractionEnabled = false
            updateClearIcons(valuesCount: searchViewModel.values.count - 1)
            UIView.animate(withDuration: 0.4) {
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            if let cell = self.searchCollectionView.cellForItem(at: targetIndex.indexPath) as? SearchFieldCell {
                cell.activate(true)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let origin = self.searchCollectionViewFlowLayout.layoutAttributes[safe: targetIndex]?.fullOrigin { /// the last field that's not the "add new" field
                    
                    self.searchCollectionViewFlowLayout.highlightingAddWordField = false
                    let (targetOrigin, _) = self.searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
                    
                    self.searchCollectionView.setContentOffset(targetOrigin, animated: true) /// go to that offset instantly
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.searchCollectionViewFlowLayout.deletedIndex = nil
                    self.searchCollectionViewFlowLayout.fallbackIndex = nil
                    self.searchViewModel.fields.remove(at: index)
                    self.searchCollectionView.deleteItems(at: [index.indexPath])
                    self.searchCollectionView.isUserInteractionEnabled = true
                    self.searchCollectionViewFlowLayout.reachedEndBeforeAddWordField = true
                    
                    if let cell = self.searchCollectionView.cellForItem(at: targetIndex.indexPath) as? SearchFieldCell {
                        cell.textField.becomeFirstResponder()
                    }
                }
            }
        } else {
            
            searchCollectionViewFlowLayout.deletedIndex = index
            searchCollectionViewFlowLayout.fallbackIndex = nil
            searchCollectionView.isUserInteractionEnabled = false
            updateClearIcons(valuesCount: searchViewModel.values.count - 1)
            UIView.animate(withDuration: 0.4) {
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchCollectionViewFlowLayout.deletedIndex = nil
                self.searchCollectionViewFlowLayout.fallbackIndex = nil
                self.searchViewModel.fields.remove(at: index)
                self.searchCollectionView.deleteItems(at: [index.indexPath])
                self.searchCollectionView.isUserInteractionEnabled = true
                
                
                /// If the focused index is the second to last, make `reachedEndBeforeAddWordField` true
                if self.searchViewModel.values.count == 1 {
                    self.searchCollectionViewFlowLayout.reachedEndBeforeAddWordField = true
                }
                
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.activate(true)
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }
    
}

