//
//  CameraVC+Lists.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
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
                for singleCont in realList.contents {
                    contents.append(singleCont)
                }
                
                editableList.contents = contents
                
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
            searchCollectionView.reloadData()
            
            switch selectedLists.count {
            case 0:
                searchTextLeftC.constant = 8
            case 1:
                searchTextLeftC.constant = 71
            case 2:
                searchTextLeftC.constant = 71 + 55 + 8
            case 3:
                searchTextLeftC.constant = 197
            default:
                searchTextLeftC.constant = 197
                let availableWidth = searchContentView.frame.width - 189
                searchBarLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                searchCollectionRightC.constant = availableWidth
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

