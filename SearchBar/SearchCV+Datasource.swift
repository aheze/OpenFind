//
//  VC+SearchCollectionView.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        
        let field = self.fields[indexPath.item]
        
        cell.setField(field) /// cell can configure itself
        cell.fieldChanged = { [weak self] field in
            self?.fields[indexPath.item] = field
        }
        
        /// setup constraints
        let (setup, _, _) = cell.showAddNew(true, changeColorOnly: false)
        setup()
        
        
        
        return cell
    }
    
    func widthOfExpandedCell(for index: Int) -> Double {
        
        var extraPadding = CGFloat(0)
        
        if index == 0 {
            extraPadding += Constants.sidePadding /// if **left edge**, add side padding
        } else {
            extraPadding += Constants.sidePeekPadding
        }
        
        if index == fields.count - 2 || index == fields.count - 1 {
            extraPadding += Constants.sidePadding /// if **right edge**, add side padding
        } else {
            extraPadding += Constants.sidePeekPadding
        }
        
        let fullWidth = searchCollectionView.frame.width
        return max(Constants.minimumHuggingWidth, fullWidth - extraPadding)
    }
    
    
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
