//
//  SearchCV+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = searchCollectionViewFlowLayout.reachedEndBeforeAddWordField
        }
    }
    
    /// highlight/unhighlight add new
    func highlight(_ shouldHighlight: Bool, generateHaptics: Bool = true, animate: Bool = true) {
        if generateHaptics {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        if shouldHighlight {
            let indexPath = IndexPath(item: searchViewModel.fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                let (_, animations, _) = cell.showAddNew(true, changeColorOnly: true)
                
                if animate {
                    UIView.animate(withDuration: 0.2) {
                        animations()
                    }
                } else {
                    animations()
                }
            }
        } else {
            let indexPath = IndexPath(item: searchViewModel.fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                let (_, animations, _) = cell.showAddNew(false, changeColorOnly: true)
                
                if animate {
                    UIView.animate(withDuration: 0.2) {
                        animations()
                    }
                } else {
                    animations()
                }
            }
        }
    }
    
    func convertAddNewCellToRegularCell(animationCompletion: @escaping (() -> Void) = {}) {
        if
            let addNewFieldIndex = searchViewModel.fields.indices.last,
            case Field.Value.addNew = searchViewModel.fields[addNewFieldIndex].text.value
        {
            searchCollectionView.isUserInteractionEnabled = false
            searchViewModel.fields[addNewFieldIndex].focused = true
            searchViewModel.fields[addNewFieldIndex].text.value = .addNew("")
            
            let indexPath = IndexPath(item: addNewFieldIndex, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                cell.field = searchViewModel.fields[addNewFieldIndex]
                cell.textField.becomeFirstResponder()
                
                let (setup, animationBlock, completion) = cell.showAddNew(false, changeColorOnly: false)
                setup()
                UIView.animate(withDuration: 0.6) {
                    animationBlock()
                } completion: { _ in
                    completion()
                    animationCompletion()
                }
            }
        }
    }
    
    func addNewCellToRight() {
        searchCollectionViewFlowLayout.highlightingAddWordField = false
        
        /// append new "Add New" cell
        let newField = Field(text: .init(value: .addNew(""), colorIndex: searchViewModel.fields.count))
        searchViewModel.fields.append(newField)
        
        let indexOfLastField = searchViewModel.fields.count - 2 /// index of the last field (not including "Add New" cell)
        
        if case .addNew(let currentString) = searchViewModel.fields[indexOfLastField].text.value {
            searchViewModel.fields[indexOfLastField].text.value = .string(currentString)
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
        if searchCollectionViewFlowLayout.reachedEndBeforeAddWordField {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = true
        } else {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = false
        }
        
        searchCollectionView.isUserInteractionEnabled = true
    }
}
