//
//  SearchCV+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: indexPath.item]?.fullOrigin {
            let targetOrigin = searchCollectionViewFlowLayout.getTargetOffsetForScrollingThere(for: CGPoint(x: origin, y: 0), velocity: .zero)
            searchCollectionView.setContentOffset(targetOrigin, animated: true)
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? SearchFieldCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = searchCollectionViewFlowLayout.reachedEndBeforeAddWordField
        }
    }
    
    
    /// append a brand-new "Add New" cell
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("decelerating")
        if searchCollectionViewFlowLayout.highlightingAddWordField {
            searchCollectionViewFlowLayout.highlightingAddWordField = false
            addNewCellToRight()
        }
    }
    
    /// highlight/unhighlight add new
    func highlight(_ shouldHighlight: Bool) {
        print("..../././......Should? \(shouldHighlight)")
        if shouldHighlight {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    let (_, animations, completion) = cell.showAddNew(true, changeColorOnly: true)
                    animations()
                    completion()
                }
            }
        } else {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    let (_, animations, completion) = cell.showAddNew(false, changeColorOnly: true)
                    animations()
                    completion()
                }
                
            }
        }
    }
    
    func convertAddNewCellToRegularCell(animationCompletion: @escaping (() -> Void) = {}) {
        if
            let addNewFieldIndex = fields.indices.last,
            case Field.Value.addNew = fields[addNewFieldIndex].value
        {
            fields[addNewFieldIndex].focused = true
            fields[addNewFieldIndex].value = .addNew("")
            
            let indexPath = IndexPath(item: addNewFieldIndex, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                cell.field = fields[addNewFieldIndex]
                cell.textField.becomeFirstResponder()
                
                let (setup, animationBlock, completion) = cell.showAddNew(false, changeColorOnly: false)
                setup()
                UIView.animate(withDuration: 0.4) {
                    animationBlock()
                } completion: { _ in
                    completion()
                    animationCompletion()
                }
            }
        }
    }
    
    func addNewCellToRight() {
        
        /// append new "Add New" cell
        let newField = Field(value: .addNew(""))
        fields.append(newField)
        
        let indexOfLastField = fields.count - 2 /// index of the last field (not including "Add New" cell)
        
        if case let .addNew(currentString) = fields[indexOfLastField].value {
            fields[indexOfLastField].value = .string(currentString)
        }
        
        searchCollectionView.reloadData() /// add the new field
        searchCollectionView.layoutIfNeeded() /// important! **Otherwise, will glitch**
        
        /// make sure the last field stays first responder
        if let cell = searchCollectionView.cellForItem(at: indexOfLastField.indexPath) as? SearchFieldCell {
            cell.textField.becomeFirstResponder()
        }
        
        if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: indexOfLastField]?.fullOrigin { /// the last field that's not the "add new" field
            let (targetOrigin, _) = self.searchCollectionViewFlowLayout.getTargetOffsetAndIndex(for: CGPoint(x: origin, y: 0), velocity: .zero)
            
            self.searchCollectionView.setContentOffset(targetOrigin, animated: false) /// go to that offset instantly
        }
        
        /// after scroll view stopped, set the content offset
        if searchCollectionViewFlowLayout.reachedEndBeforeAddWordField {
            print("REACHED END.")
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = true
        } else {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = false
        }
    }
}


