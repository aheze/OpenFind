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
}

