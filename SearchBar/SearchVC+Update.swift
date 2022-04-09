//
//  SearchVC+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchViewController {
    func listsChanged(newLists: [List]) {
        print("->>>> Lists are now: \(newLists) vs.. \(self.realmModel.lists)")
        
        var fields = [Field]()
        var deletedListsFieldIndices = [Int]() /// indices of deleted lists in fields
        for index in searchViewModel.fields.indices {
            let currentField = searchViewModel.fields[index]
            switch currentField.value {
            case .list(let list):
                let updatedList = newLists.first { $0.id == list.id }
                if let updatedList = updatedList {
                    let updatedField = Field(configuration: currentField.configuration, value: .list(updatedList), overrides: currentField.overrides)
                    fields.append(updatedField)
                } else {
                    let emptyField = Field(configuration: currentField.configuration, value: .word(.init()), overrides: currentField.overrides)
                    fields.append(emptyField)
                    deletedListsFieldIndices.append(index)
                }
            default:
                fields.append(currentField)
            }
        }
        
        searchViewModel.updateFields(fields: fields, notify: true)
        
        print("cur: \(collectionViewModel.focusedCellIndex)")
        if
            let currentIndex = collectionViewModel.focusedCellIndex,
            let cell = searchCollectionView.cellForItem(at: currentIndex.indexPath)
        {
            print("About to fismiss.")
            if let existingPopover = view.popover(tagged: PopoverIdentifier.fieldSettingsIdentifier) {
                if deletedListsFieldIndices.contains(currentIndex) {
                    print("dismissing popover.")
                    dismiss(existingPopover)
                } else {
                    print("updating popover.")
                    let updatedPopover = getPopover(for: currentIndex, from: cell)
                    replace(existingPopover, with: updatedPopover)
                }
            }
        }
        reload()
    }
}
