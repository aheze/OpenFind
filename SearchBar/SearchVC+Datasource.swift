//
//  SearchVC+DataSource.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController {
    func createFlowLayout() -> SearchCollectionViewFlowLayout {
        let flowLayout = SearchCollectionViewFlowLayout(
            searchViewModel: searchViewModel,
            collectionViewModel: collectionViewModel
        )
        flowLayout.scrollDirection = .horizontal
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    func getWidthOfExpandedCell(for index: Int) -> Double {
        var extraPadding = CGFloat(0)
        
        if index == 0 {
            extraPadding += searchCollectionViewFlowLayout.sidePaddingLeft /// if **left edge**, add side padding
        } else {
            extraPadding += searchCollectionViewFlowLayout.sidePeekPaddingLeft
        }
        
        var fieldsCount = searchViewModel.fields.count
        
        /// The last field (not add new) is being deleted, make the previous one (fallback) full width
        if collectionViewModel.fallbackIndex != nil {
            fieldsCount -= 1
        }
        
        if index == fieldsCount - 2 || index == fieldsCount - 1 {
            extraPadding += searchCollectionViewFlowLayout.sidePaddingRight /// if **right edge**, add side padding
        } else {
            extraPadding += searchCollectionViewFlowLayout.sidePeekPaddingRight
        }
        
        let fullWidth = searchCollectionView.bounds.width
        return max(searchViewModel.configuration.minimumHuggingWidth, fullWidth - extraPadding)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.fields.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCell(for: indexPath.item)
    }
}
