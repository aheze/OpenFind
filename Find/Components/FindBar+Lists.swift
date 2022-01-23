//
//  FindBar+Lists.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension FindBar {
    func refreshLists() {
        if let listCategories = listCategories {
            var newSelectedLists = [EditableFindList]()
            var newUnselectedLists = [EditableFindList]()
            var allLists = [EditableFindList]()
            
            for (index, realList) in listCategories.enumerated() {
                var listIsSelected = false
                
                let editableList = EditableFindList()
                editableList.name = realList.name
                editableList.descriptionOfList = realList.descriptionOfList
                editableList.iconImageName = realList.iconImageName
                editableList.iconColorName = realList.iconColorName
                editableList.dateCreated = realList.dateCreated
                editableList.orderIdentifier = index
                
                var contents = [String]()
                for singleCont in reallist.words {
                    contents.append(singleCont)
                }
                
                editablelist.words = contents
                
                for selectedList in selectedLists {
                    if selectedList.dateCreated == realList.dateCreated {
                        listIsSelected = true
                        newSelectedLists.append(editableList)
                        break
                    }
                }
                if listIsSelected == false {
                    newUnselectedLists.append(editableList)
                }
                
                allLists.append(editableList)
            }
            editableListCategories = allLists
            selectedLists = newSelectedLists
            injectListDelegate?.resetWithLists(lists: newUnselectedLists)

            sortSearchTerms()
            collectionView.reloadData()

            switch selectedLists.count {
            case 0:
                searchLeftC.constant = 0
            case 1:
                searchLeftC.constant = 35 + 3
            case 2:
                searchLeftC.constant = 73 + 3
            case 3:
                searchLeftC.constant = 111 + 3
            default:
                searchLeftC.constant = 111 + 3
                let availableWidth = contentView.frame.width - 123
                collViewRightC.constant = availableWidth
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
    }
}
