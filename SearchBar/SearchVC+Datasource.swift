//
//  SearchVC+Datasource.swift
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
        return configureCell(for: indexPath.item)
    }
    
    func widthOfExpandedCell(for index: Int) -> Double {
        var extraPadding = CGFloat(0)
        
        if index == 0 {
            extraPadding += searchCollectionViewFlowLayout.sidePadding /// if **left edge**, add side padding
        } else {
            extraPadding += searchCollectionViewFlowLayout.sidePeekPadding
        }
        
        var fieldsCount = searchViewModel.fields.count
        
        /// The last field (not add new) is being deleted, make the previous one (fallback) full width
        if searchCollectionViewFlowLayout.fallbackIndex != nil {
            fieldsCount -= 1
        }
        
        if index == fieldsCount - 2 || index == fieldsCount - 1 {
            extraPadding += searchCollectionViewFlowLayout.sidePadding /// if **right edge**, add side padding
        } else {
            extraPadding += searchCollectionViewFlowLayout.sidePeekPadding
        }
        
        let fullWidth = searchCollectionView.bounds.width
//        - searchCollectionView.safeAreaInsets.left
//        - searchCollectionView.safeAreaInsets.right
        return max(searchViewModel.configuration.minimumHuggingWidth, fullWidth - extraPadding)
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
