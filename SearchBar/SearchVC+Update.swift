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
        var fields = [Field]()
        var deletedListsFieldIndices = [Int]() /// indices of deleted lists in fields
        for index in searchViewModel.fields.indices {
            let currentField = searchViewModel.fields[index]
            
            /// update lists if needed
            switch currentField.value {
            case .list(let list, let originalText):
                let updatedList = newLists.first { $0.id == list.id }
                if let updatedList = updatedList {
                    let updatedField = Field(
                        configuration: currentField.configuration,
                        value: .list(updatedList, originalText: originalText),
                        overrides: currentField.overrides
                    )
                    fields.append(updatedField)
                } else {
                    let emptyField = Field(
                        configuration: currentField.configuration,
                        value: .word(.init()),
                        overrides: currentField.overrides
                    )
                    fields.append(emptyField)
                    deletedListsFieldIndices.append(index)
                }
            default:
                fields.append(currentField)
            }
        }
        
        searchViewModel.updateFields(fields: fields, notify: true)
        reload()
    }
}
