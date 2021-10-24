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
    
    
    func shouldHighlight(_ shouldHighlight: Bool) {
        if shouldHighlight {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    cell.contentView.backgroundColor = UIColor.red
                }
            }
        } else {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.2) {
                    cell.contentView.backgroundColor = UIColor.gray
                }
            }
        }
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if searchCollectionViewFlowLayout.showingAddWordField {
            let indexPath = IndexPath(item: fields.count - 1, section: 0)
            if let cell = searchCollectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                UIView.animate(withDuration: 0.8) {
                    cell.contentView.backgroundColor = UIColor.gray
                }
            }
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if searchCollectionViewFlowLayout.showingAddWordField {
            searchCollectionViewFlowLayout.showingAddWordField = false
            
            var newField = Field(value: .addNew)
            newField.fieldHuggingWidth = getFieldHuggingWidth(fieldText: newField.getText())
            
            self.fields.append(newField)
            searchCollectionView.reloadData() /// add the new field
            searchCollectionView.layoutIfNeeded() /// important!
            
            if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: self.fields.count - 2]?.fullOrigin { /// the last field that's not the "add new" field
                let targetOrigin = self.searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: origin, y: 0))
                self.searchCollectionView.setContentOffset(targetOrigin, animated: false) /// go to that offset instantly
            }
        }
        
        if searchCollectionViewFlowLayout.reachedEndBeforeAddWordField {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = true
        } else {
            searchCollectionViewFlowLayout.shouldUseOffsetWithAddNew = false
        }
    }
    
}

