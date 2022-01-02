//
//  SearchVC+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController {
    func createFlowLayout() -> SearchCollectionViewFlowLayout {
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getFullCellWidth = { [weak self] index in
            self?.widthOfExpandedCell(for: index) ?? 300
        }
        flowLayout.getFields = { [weak self] in
            self?.searchViewModel.fields ?? [Field]()
        }
        flowLayout.highlightAddNewField = { [weak self] shouldHighlight in
            self?.highlight(shouldHighlight)
        }
        flowLayout.focusedCellIndexChanged = { [weak self] oldCellIndex, newCellIndex in
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
        
        flowLayout.convertAddNewToRegularCellInstantly = { [weak self] completion in
            
            /// make it blue first
            self?.highlight(true, generateHaptics: true, animate: false)
            self?.convertAddNewCellToRegularCell { [weak self] in
                self?.addNewCellToRight()
                completion()
            }
        }
        
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
}
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
        
        let indexPath = IndexPath(item: searchViewModel.fields.count - 1, section: 0)
        if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
            UIView.animate(withDuration: 0.2) {
                cell.contentView.backgroundColor = shouldHighlight ? SearchConstants.highlightedFieldBackgroundColor : SearchConstants.fieldBackgroundColor
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
                    animationCompletion()
                }
            }
        }
    }
    
    func addNewCellToRight() {
        searchCollectionViewFlowLayout.highlightingAddWordField = false
        
        /// append new "Add New" cell
        let defaultColor = Constants.defaultHighlightColor.getFieldColor(for: searchViewModel.fields.count)
        let newField = Field(
            value: .addNew(
                .init(
                    string: "",
                    color: defaultColor.hex
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
                    color: defaultColor.hex
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
        if searchCollectionViewFlowLayout.reachedEndBeforeAddWordField {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = true
        } else {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = false
        }
        
        searchCollectionView.isUserInteractionEnabled = true
    }
}
