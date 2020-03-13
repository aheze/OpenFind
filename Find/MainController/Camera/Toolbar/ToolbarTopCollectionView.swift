//
//  ToolbarTopCollectionView.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource, ToolbarButtonPressed, SelectedList, StartedEditing {
    func buttonPressed(button: ToolbarButtonType) {
        switch button {
        case .removeAll:
            removeAllLists()
        case .newMatch:
            if let searchText = newSearchTextField.text {
                newSearchTextField.text = "\(searchText)\u{2022}"
            }
        case .done:
            view.endEditing(true)
            if insertingListsCount == 0 {
                updateListsLayout(toType: "doneAndShrink")
            } else {
                isSchedulingList = true
            }
        }
    }
    
    func addList(list: EditableFindList) {
        print("add1")
        selectedLists.insert(list, at: 0)
        if selectedLists.count <= 1 {
            updateListsLayout(toType: "addListsNow")
        }
        print("add2")
    
            let indexP = IndexPath(item: 0, section: 0)
            searchCollectionView.performBatchUpdates({
                print("add3")
                self.searchCollectionView.insertItems(at: [indexP])
                self.insertingListsCount += 1
            }, completion: { _ in
                self.insertingListsCount -= 1
                if self.isSchedulingList == true {
                    if self.insertingListsCount == 0 {
                        self.isSchedulingList = false
                        self.updateListsLayout(toType: "doneAndShrink")
                    }
                }
            })
    
        print("add14")
        print("add121")
            sortSearchTerms()
    }
    
    func startedEditing(start: Bool) {
        if start == true {
            if selectedLists.count == 0 {
                updateListsLayout(toType: "onlyTextBox")
            } else {
                updateListsLayout(toType: "addListsNow")
            }
        } else {
            updateListsLayout(toType: "doneAndShrink")
        }
    }
    
    func tempResetLists() {
        
        var tempArray = [EditableFindList]()
        for singleList in selectedLists {
            tempArray.append(singleList)
        }
        
        
        selectedLists.removeAll()
        searchCollectionView.reloadData()
        for temp in tempArray {
            injectListDelegate?.addList(list: temp)
        }
        searchCollectionView.performBatchUpdates({
            searchCollectionView.reloadData()
        }, completion: nil)
        updateListsLayout(toType: "prepareForDisplayNew")
    }
    func loadListsRealm() {
        
        listCategories = realm.objects(FindList.self)
        selectedLists.removeAll()
        editableListCategories.removeAll()
        
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        if let lC = listCategories {
            for (index, singleL) in lC.enumerated() {
                
                let editList = EditableFindList()
                
                editList.name = singleL.name
                editList.descriptionOfList = singleL.descriptionOfList
                editList.iconImageName = singleL.iconImageName
                editList.iconColorName = singleL.iconColorName
                editList.orderIdentifier = index
                var contents = [String]()
                for singleCont in singleL.contents {
                    contents.append(singleCont)
                }
                
                editList.contents = contents
                
                editableListCategories.append(editList)
            }
        }
        print("Loading lists")
        for singL in editableListCategories {
            print(singL.name)
        }
        
        searchCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return selectedLists.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
        let listNumber = selectedLists[indexPath.item]
        if let list = listCategories?[listNumber.orderIdentifier] {
            
            cell.backgroundColor = UIColor(hexString: list.iconColorName)
            cell.layer.cornerRadius = 6
            cell.nameLabel.text = list.name
            print("cont size: \(cell.nameLabel.intrinsicContentSize)")
            if searchShrunk == true {
                cell.imageRightC.constant = 8
                print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                UIView.animate(withDuration: 0.3, animations: {
    
                    cell.nameLabel.alpha = 0
                    cell.layoutIfNeeded()
                })
            } else {
                cell.imageRightC.constant = cell.nameLabel.intrinsicContentSize.width + 16
                print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                UIView.animate(withDuration: 0.3, animations: {
        
                        cell.nameLabel.alpha = 1
                        cell.layoutIfNeeded()
                    })
            }
            

            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
            let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
            
            cell.imageView.image = newImage
            
        }
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if searchShrunk == false {
            print("pressed search cell")
            let list = selectedLists[indexPath.item]
            
            selectedLists.remove(at: indexPath.item)
            searchCollectionView.deleteItems(at: [indexPath])
            
            if selectedLists.count == 0 {
                updateListsLayout(toType: "removeListsNow")
            }
            injectListDelegate?.addList(list: list)
            sortSearchTerms()
        } else {
            newSearchTextField.becomeFirstResponder()
            if selectedLists.count == 0 {
                updateListsLayout(toType: "onlyTextBox")
            } else {
                updateListsLayout(toType: "addListsNow")
            }
        }
        
    }
}




