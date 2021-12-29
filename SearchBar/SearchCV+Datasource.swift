//
//  VC+SearchCollectionView.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.fields.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        let field = searchViewModel.fields[indexPath.item]
        
        cell.setField(field) /// cell can configure itself
        cell.fieldChanged = { [weak self] field in
            self?.searchViewModel.fields[indexPath.item] = field
        }
        cell.leftView.findIconView.setTint(color: field.text.selectedColor ?? field.text.defaultColor, alpha: field.text.colorAlpha)
        
        /// setup constraints
        let (setup, _, _) = cell.showAddNew(true, changeColorOnly: false)
        setup()
        
        cell.leftViewTapped = { [weak self] in
            self?.presentPopover(for: indexPath.item, from: cell)
        }
        
        cell.triggerButton.isEnabled = !field.focused
        cell.entireViewTapped = { [weak self] in
            guard let self = self else { return }
            if let origin = self.searchCollectionViewFlowLayout.layoutAttributes[safe: indexPath.item]?.fullOrigin {
                let targetOrigin = self.searchCollectionViewFlowLayout.getTargetOffsetForScrollingThere(for: CGPoint(x: origin, y: 0), velocity: .zero)
                self.searchCollectionView.setContentOffset(targetOrigin, animated: true)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? SearchFieldCell {
                cell.textField.becomeFirstResponder()
            }
        }
        
        return cell
    }
    
    func widthOfExpandedCell(for index: Int) -> Double {
        var extraPadding = CGFloat(0)
        
        if index == 0 {
            extraPadding += SearchConstants.sidePadding /// if **left edge**, add side padding
        } else {
            extraPadding += SearchConstants.sidePeekPadding
        }
        
        if index == searchViewModel.fields.count - 2 || index == searchViewModel.fields.count - 1 {
            extraPadding += SearchConstants.sidePadding /// if **right edge**, add side padding
        } else {
            extraPadding += SearchConstants.sidePeekPadding
        }
        
        let fullWidth = searchCollectionView.frame.width
        return max(SearchConstants.minimumHuggingWidth, fullWidth - extraPadding)
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
