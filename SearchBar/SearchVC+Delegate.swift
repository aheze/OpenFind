//
//  SearchVC+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            searchViewModel.collectionViewModel.shouldUseOffsetWithAddNew = searchViewModel.collectionViewModel.reachedEndBeforeAddWordField
        }
    }
    
    /// highlight/unhighlight add new
    func highlight(_ shouldHighlight: Bool, generateHaptics: Bool = true, animate: Bool = true) {
        if generateHaptics {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        let indexPath = IndexPath(item: searchViewModel.fields.count - 1, section: 0)
        if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
            UIView.animate(withDuration: 0.2) {
                if shouldHighlight {
                    cell.contentView.backgroundColor = self.searchViewModel.configuration.fieldHighlightedBackgroundColor
                } else {
                    cell.contentView.backgroundColor = self.searchViewModel.configuration.fieldBackgroundColor
                }
            }
        }
    }
    
    /// First called, then `addNewCellToRight` is called in the completion
    func convertAddNewCellToRegularCell(animationCompletion: @escaping (() -> Void) = {}) {
        if let addNewFieldIndex = searchViewModel.fields.indices.last {
            searchCollectionView.isUserInteractionEnabled = false
            
            let indexPath = IndexPath(item: addNewFieldIndex, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                cell.textField.becomeFirstResponder()
                
                let (setup, animationBlock, completion) = cell.showAddNew(false)
                setup()
                UIView.animate(withDuration: 0.6) {
                    animationBlock()
                } completion: { _ in
                    completion()
                    DispatchQueue.main.async {
                        animationCompletion()
                    }
                }
            }
        }
    }
    
    func addNewCellToRight() {
        searchViewModel.collectionViewModel.highlightingAddWordField = false
        
        /// append new "Add New" cell
        let newField = Field(
            configuration: searchViewModel.configuration,
            value: .addNew(
                .init(
                    string: "",
                    color: Constants.defaultHighlightColor.getFieldColor(for: searchViewModel.fields.count).hex
                )
            )
        )
        searchViewModel.fields.append(newField)
        
        let indexOfLastField = searchViewModel.fields.count - 2 /// index of the last field (not including "Add New" cell)
        
        /// Set the string of the new word field (previously an add-new field)
        if case .addNew(let word) = searchViewModel.fields[indexOfLastField].value {
            searchViewModel.fields[indexOfLastField].value = .word(
                .init(
                    string: word.string,
                    color: Constants.defaultHighlightColor.getFieldColor(for: indexOfLastField).hex
                )
            )
        }
        
        searchCollectionView.reloadData() /// add the new field
        searchCollectionView.layoutIfNeeded() /// important! **Otherwise, will glitch**
        
        /// make sure the last field stays first responder
        if let cell = searchCollectionView.cellForItem(at: indexOfLastField.indexPath) as? SearchFieldCell {
            cell.textField.becomeFirstResponder()
        }
        
        if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: indexOfLastField]?.fullOrigin { /// the last field that's not the "add new" field
            let (targetOrigin, _) = searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
            
            searchCollectionView.setContentOffset(targetOrigin, animated: false) /// go to that offset instantly
        }
        
        /// after scroll view stopped, set the content offset
        if searchViewModel.collectionViewModel.reachedEndBeforeAddWordField {
            searchViewModel.collectionViewModel.shouldUseOffsetWithAddNew = true
        } else {
            searchViewModel.collectionViewModel.shouldUseOffsetWithAddNew = false
        }
        
        searchCollectionView.isUserInteractionEnabled = true
    }
}
