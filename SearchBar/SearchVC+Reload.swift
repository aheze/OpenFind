//
//  SearchVC+Reload.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchViewController {
    /// update the collection view.
    func reload() {
        searchCollectionView.reloadData()

        if let focusedIndex = collectionViewModel.focusedCellIndex {
            let targetOrigin = searchCollectionViewFlowLayout.getPointForCell(at: focusedIndex)

            searchCollectionView.contentOffset = targetOrigin
            searchCollectionViewFlowLayout.invalidateLayout()
        }
    }
    
    /// call after default highlight color changed
    func updateWordColors() {
        for index in searchViewModel.fields.indices {
            var field = searchViewModel.fields[index]
            var needReload = false
            switch field.value {
            case .word(var word):
                word.color = UIColor(hex: self.realmModel.highlightsColor).getFieldColor(for: index, realmModel: self.realmModel).hex
                field.value = .word(word)
                searchViewModel.updateField(at: index, with: field, notify: true)
                needReload = true
            case .addNew(var word):
                word.color = UIColor(hex: self.realmModel.highlightsColor).getFieldColor(for: index, realmModel: self.realmModel).hex
                field.value = .addNew(word)
                searchViewModel.updateField(at: index, with: field, notify: true)
                needReload = true
            default: break
            }
            
            if needReload {
                if let cell = searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    configureCell(cell, for: index)
                }
            }
        }
    }
}
