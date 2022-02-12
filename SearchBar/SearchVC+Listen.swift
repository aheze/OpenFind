//
//  SearchVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SearchViewController {
    func listenToCollectionView() {
        searchViewModel.collectionViewModel.getFullCellWidth = { [weak self] index in
            self?.getWidthOfExpandedCell(for: index) ?? 300
        }
        searchViewModel.collectionViewModel.highlightAddNewField = { [weak self] shouldHighlight in
            self?.highlight(shouldHighlight)
        }
        
        searchViewModel.collectionViewModel.convertAddNewCellToRegularCell = { [weak self] completion in
            
            /// make it blue first
            self?.highlight(true, generateHaptics: true, animate: false)
            self?.convertAddNewCellToRegularCell { [weak self] in
                self?.addNewCellToRight()
                completion()
            }
        }
        
        searchViewModel.collectionViewModel.focusedCellIndexChanged = { [weak self] oldCellIndex, newCellIndex in
            guard let self = self else { return }
            
            /// only active the newly-focused cell if previously a text field was active
            var activateNewCell = false
            if let oldCellIndex = oldCellIndex {
                if let cell = self.searchCollectionView.cellForItem(at: oldCellIndex.indexPath) as? SearchFieldCell {
                    if self.searchViewModel.fields.indices.contains(oldCellIndex) {
                        self.searchViewModel.fields[oldCellIndex].showingDeleteButton = false
                    }

                    cell.activate(false)
                    
                    if cell.textField.isFirstResponder {
                        cell.resignFirstResponder()
                        activateNewCell = true
                    }
                }
            }
            if let newCellIndex = newCellIndex, self.searchViewModel.fields.indices.contains(newCellIndex) {
                if let cell = self.searchCollectionView.cellForItem(at: newCellIndex.indexPath) as? SearchFieldCell {
                    if activateNewCell {
                        cell.textField.becomeFirstResponder()
                    }
                    cell.activate(true)
                }
            }
        }
        
    }
}
