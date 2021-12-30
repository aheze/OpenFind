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
        setClearIcon(for: cell, text: text)
        
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
            self.searchViewModel.fields[index].value = .string(text)
            self.updateClearIcons()
            
        }
        cell.leftView.findIconView.setTint(
            color: field.attributes.selectedColor ?? field.attributes.defaultColor,
            alpha: field.attributes.alpha
        )
        
        
        cell.leftViewTapped = { [weak self] in
            self?.presentPopover(for: index, from: cell)
        }
        cell.rightViewTapped = { [weak self] in
            guard let self = self else { return }
            
            let value = self.searchViewModel.fields[index].value
            if value.getText().isEmpty {
                self.removeCell(at: index)
            } else {
                cell.textField.text = ""
                self.searchViewModel.fields[index].value = .string("")
                self.setClearIcon(for: cell, text: "")
            }
        }
        
        cell.triggerButton.isEnabled = !field.focused
        cell.entireViewTapped = { [weak self] in
            guard let self = self else { return }
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
    
    func updateClearIcons() {
        let values = self.searchViewModel.values
        
        for index in values.indices {
            let field = searchViewModel.fields[index]
            if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                setClearIcon(for: cell, text: field.value.getText())
            }
        }
    }
    
    func setClearIcon(for cell: SearchFieldCell, text: String) {
        if text.isEmpty {
            if searchViewModel.values.count >= 2 {
                cell.rightView.clearIconView.setState(.delete, animated: true)
            } else {
                cell.rightView.clearIconView.setState(.hidden, animated: true)
            }
        } else {
            cell.rightView.clearIconView.setState(.clear, animated: true)
        }
    }
    
    func removeCell(at index: Int) {
        
        if searchViewModel.values.count >= 2 {
            
            searchCollectionViewFlowLayout.deletedIndex = index
            UIView.animate(withDuration: 2) {
                
                self.searchCollectionViewFlowLayout.invalidateLayout()
                self.searchCollectionView.layoutIfNeeded()
            }
            
            
            if let cell = searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                cell.textField.becomeFirstResponder()
            }
//            searchViewModel.fields.remove(at: index)
//            searchCollectionViewFlowLayout.deletingIndex = index
//            searchCollectionView.deleteItems(at: [index.indexPath])
//
//            searchCollectionView.reloadData() /// add the new field
//            searchCollectionView.layoutIfNeeded() /// important! **Otherwise, will glitch**
            
            /// make sure the last field stays first responder
//            if let cell = searchCollectionView.cellForItem(at: 0.indexPath) as? SearchFieldCell {
//                cell.textField.becomeFirstResponder()
//            }
            
//            if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: 0]?.fullOrigin { /// the last field that's not the "add new" field
////                let (targetOrigin, _) = searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
////                print("t: \(targetOrigin)")
//                searchCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true) /// go to that offset instantly
//            }
            //                    self.searchCollectionView.deleteItems(at: [index.indexPath])
        }
    }
    
}

