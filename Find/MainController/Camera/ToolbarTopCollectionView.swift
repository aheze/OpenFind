//
//  ToolbarTopCollectionView.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource {
    
    func tempResetLists() {
        
        selectedLists.removeAll()
        editableListCategories.removeAll()
        searchCollectionView.performBatchUpdates({
            searchCollectionView.reloadData()
        }, completion: nil)
        
        listsCollectionView.performBatchUpdates({
            listsCollectionView.reloadData()
        }, completion: nil)
//        listsCollectionView.reloadData()
        updateListsLayout(toType: "prepareForDisplayNew")
    }
    func loadListsRealm() {
        
        listCategories = realm.objects(FindList.self)
        selectedLists.removeAll()
        editableListCategories.removeAll()
        
        
//        print(listCategories)
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
//        let flowLayout = listsCollectionView.collectionViewLayout
//        flowLayout.estimated
        
        print("Loading lists")
        for singL in editableListCategories {
            print(singL.name)
        }
        
        searchCollectionView.reloadData()
        listsCollectionView.reloadData()
//        listsToolbarLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100100 {
            return editableListCategories.count
        } else { ///The search bar 100101
            return selectedLists.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var cell = UICollectionViewCell()
        if collectionView.tag == 100100 {
            let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
//            if let list = listCategories?[indexPath.row] {
            let list = editableListCategories[indexPath.item]
                cell.labelText.text = list.name
                cell.backgroundColor = UIColor(hexString: list.iconColorName)
                cell.layer.cornerRadius = 6
                let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
                let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
                
                cell.imageView.image = newImage
//            }
            return cell
        } else { ////1001000090 search collection view searchCell
           // print("Dequeue, indexPath: \(indexPath.item)")
            let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
            let listNumber = selectedLists[indexPath.item]
            if let list = listCategories?[listNumber.orderIdentifier] {
//                print("order id: \(list)")
                
                
                cell.backgroundColor = UIColor(hexString: list.iconColorName)
                cell.layer.cornerRadius = 6
//                var newLabelFrame = cell.nameLabel.frame
//                print(newLabelFrame)
                print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                if searchShrunk == true {
                   // print("SHRINK MODE")
                    cell.nameLabel.text = ""
                    cell.labelRightC.constant = 0
//                    newLabelFrame.size.width = 0
//                    cell.labelWidth.constant = 0
                    print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                } else {
                  //  print("EXPAND MODE")
                    cell.nameLabel.text = list.name
                    cell.labelRightC.constant = 8
//                    newLabelFrame.size.width = cell.nameLabel.intrinsicContentSize.width
//                    cell.labelWidth.constant = cell.nameLabel.intrinsicContentSize.width
                    print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    
//                    cell.nameLabel.frame = newLabelFrame
                    cell.layoutIfNeeded()
                })
                
                let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
                let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
                
                cell.imageView.image = newImage
                
            }
            
            return cell
        }
            
//            if let list = listCategories?[indexPath.row] {
//                cell.labelText.text = list.name
//                cell.backgroundColor = UIColor(hexString: list.iconColorName)
//                cell.layer.cornerRadius = 6
//                let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
//                let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//
//                cell.imageView.image = newImage
//            }
//            return cell
//        }
    }
//    func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      sizeForItemAt indexPath: IndexPath) -> CGSize {
//       // let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
//        //let itemSize = cell.button.frame.size.width
//        return CGSize(width: 120, height: CGFloat(38))
//    }

    func calculateWhereToPlaceComponent(component: EditableFindList, placeInSecondCollectionView: IndexPath) {
        let componentOrderID = component.orderIdentifier
        print("calc")
        var indexPathToAppendTo = 0
        for (index, singleComponent) in editableListCategories.enumerated() {
            ///We are going to check if the singleComponent's order identifier is smaller than componentOrderID.
            ///If it is smaller, we know we must insert the cell ONE to the right of this indexPath.
            if singleComponent.orderIdentifier < componentOrderID {
                indexPathToAppendTo = index + 1
            }
        }
        print("index... \(indexPathToAppendTo)")
        ///Now that we know where to append the green cell, let's do it!
        editableListCategories.insert(component, at: indexPathToAppendTo)
        let newIndexPath = IndexPath(item: indexPathToAppendTo, section: 0)
        listsCollectionView.insertItems(at: [newIndexPath])

        //we must remove the red cell now.
        selectedLists.remove(at: placeInSecondCollectionView.item)
        searchCollectionView.deleteItems(at: [placeInSecondCollectionView])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 100100 {
            print("select cell")
            let newList = editableListCategories[indexPath.item]
            selectedLists.insert(newList, at: 0)
            print(selectedLists)
            
            let indexP = IndexPath(item: 0, section: 0)
            searchCollectionView.insertItems(at: [indexP])
//            listViewCollectionView.insertItems(at: [indexP])
            
            editableListCategories.remove(at: indexPath.item)
            listsCollectionView.deleteItems(at: [indexPath])
            if selectedLists.count <= 1 {
                updateListsLayout(toType: "addListsNow")
            }
            
            sortSearchTerms()
//            var contained = [String]()
            
            
            
            
            
//            print("start_______________")
//            print("dup strings: \(duplicatedStrings)")
//            print("find list: \(currentFindMatches.count)")
//            print("search field dup: \(cameAcrossSearchFieldText)")
//            for list in currentFindMatches {
//                print("list")
//                for match in list.contents {
//                   print("Match: \(match)")
//                }
//            }
//            print("end_______________")
//            print("one...")
//            print(contained)
//            containedList = contained.uniques
//            print(containedList)
            
          //  editableListCategories
            //listsViewWidth.up
        } else {
            if searchShrunk == false {
            print("pressed search cell")
            let list = selectedLists[indexPath.item]
            calculateWhereToPlaceComponent(component: list, placeInSecondCollectionView: indexPath)
            
            if selectedLists.count == 0 {
                updateListsLayout(toType: "removeListsNow")
            }
            sortSearchTerms()
//            newList.name = list.name
//            newList.descriptionOfList = list.descriptionOfList
//            newList.iconImageName = list.iconImageName
//            newList.iconColorName = list.iconColorName
//
//            var contents = [String]()
//            for singleCont in list.contents {
//                contents.append(singleCont)
//            }
            
//            newList.contents = contents
            } else {
                //focus cell
            }
        }
    }
}




