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
            let targetOrigin = searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: origin, y: 0))
            searchCollectionView.setContentOffset(targetOrigin, animated: true)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = searchCollectionViewFlowLayout.reachedEndBeforeAddWordField
        }
    }
    
    /// highlight/unhighlight add new
    func shouldHighlight(_ shouldHighlight: Bool) {
        if shouldHighlight {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    cell.showAddNew(true, changeColorOnly: true)
                }
            }
        } else {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    cell.showAddNew(false, changeColorOnly: true)
                }
            }
        }
    }
    
    /// convert "Add New" cell into a normal field
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if searchCollectionViewFlowLayout.highlightingAddWordField {
            
            /// get index of add new cell
            if let addNewFieldIndex = fields.indices.last {
                
                let value = Field.Value.addNew(.animatingToFull)
                fields[addNewFieldIndex].value = value
                
                let indexPath = IndexPath(item: addNewFieldIndex, section: 0)
                if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                    
                    /// stop other animations
                    cell.setField(fields[addNewFieldIndex]) 
                    UIView.animate(withDuration: 0.5) {
                        cell.showAddNew(false, changeColorOnly: false)
                    }
                }
            }
        }
    }
    
    /// append a brand-new "Add New" cell
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if searchCollectionViewFlowLayout.highlightingAddWordField {
            searchCollectionViewFlowLayout.highlightingAddWordField = false
            
            /// append new "Add New" cell
            let newField = Field(value: .addNew(.hugging))
            fields.append(newField)
            
            let indexOfLastField = self.fields.count - 2 /// index of the last field (not including "Add New" cell)
            fields[indexOfLastField].value = .string("")
            
            searchCollectionView.reloadData() /// add the new field
            searchCollectionView.layoutIfNeeded() /// important! **Otherwise, will glitch**
            
            if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: fields.count - 2]?.fullOrigin { /// the last field that's not the "add new" field
                let targetOrigin = self.searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: origin, y: 0))
                self.searchCollectionView.setContentOffset(targetOrigin, animated: false) /// go to that offset instantly
            }
            
            /// after scroll view stopped, set the content offset
            if searchCollectionViewFlowLayout.reachedEndBeforeAddWordField {
                searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = true
            } else {
                searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = false
            }
        }
    }
}


