//
//  SetUpRamReel.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import SnapKit
import VideoToolbox

protocol InjectLists: class {
    func addList(list: EditableFindList)
    func resetWithLists(lists: [EditableFindList])
}
//protocol UpdateToolbar: class {
//    func updateToolbar()
//}
/// Ramreel setup

extension ViewController: ToolbarButtonPressed, SelectedList, StartedEditing {
  
    
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
        selectedLists.insert(list, at: 0)
        if selectedLists.count <= 1 {
            updateListsLayout(toType: "addListsNow")
        }

            let indexP = IndexPath(item: 0, section: 0)
            searchCollectionView.performBatchUpdates({
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
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return selectedLists.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
        let listNumber = selectedLists[indexPath.item]
        if let list = listCategories?[listNumber.orderIdentifier] {

            cell.backgroundColor = UIColor(hexString: list.iconColorName)
            cell.layer.cornerRadius = 6
               
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
            let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)

            cell.imageView.image = newImage
            
//            print("cont size: \(cell.nameLabel.intrinsicContentSize)")
            if searchShrunk == true {
                print("SHRUNK")
                cell.imageRightC.constant = 0
//                print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                UIView.animate(withDuration: 0.3, animations: {
                    cell.nameLabel.text = ""
                    cell.nameLabel.alpha = 0
                    cell.layoutIfNeeded()
                })
            } else {
                cell.imageRightC.constant = 8
                print("NOT SHRUNK")
                print("cont size: \(cell.nameLabel.intrinsicContentSize)")
                UIView.animate(withDuration: 0.3, animations: {
                cell.nameLabel.text = list.name
                cell.nameLabel.alpha = 1
                    cell.layoutIfNeeded()
                })
            }



            

        }

        return cell

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if searchShrunk == false {
            print("pressed search cell")
            let list = selectedLists[indexPath.item]

            selectedLists.remove(at: indexPath.item)
            searchCollectionView.deleteItems(at: [indexPath])
            
//            searchCollectionView.reloadData()

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
//        print("Loading lists")
//        for singL in editableListCategories {
//            print(singL.name)
//        }

        searchCollectionView.reloadData()
//        updateToolbar?.updateToolbar()
    }
    func tempResetLists() {

        var tempArray = [EditableFindList]()
        for singleList in selectedLists {
            tempArray.append(singleList)
        }


        selectedLists.removeAll()
        searchCollectionView.reloadData()
        
//        injectListDelegate?.resetWithLists(lists: tempArray)
        for temp in tempArray {
            injectListDelegate?.addList(list: temp)
        }
        searchCollectionView.performBatchUpdates({
            searchCollectionView.reloadData()
        }, completion: nil)
        updateListsLayout(toType: "prepareForDisplayNew")
    }
    func setUpSearchBar() {

        textLabel.alpha = 0
        listsLabel.alpha = 0
        tapToRemoveLabel.alpha = 0
        arrowDownImage.alpha = 0
        
        searchContentView.layer.cornerRadius = 12
        searchContentView.clipsToBounds = true
        
        newSearchTextField.layer.cornerRadius = 8
        
        let toolbar = ListToolBar()
        toolbar.pressedButton = self
        toolbar.selectedList = self
//        toolbar.changedText = self
        toolbar.startedEditing = self
        injectListDelegate = toolbar
//        updateToolbar = toolbar
        
        loadListsRealm()
        
        toolbar.frame.size = CGSize(width: deviceSize.width, height: 80)
//        toolbar.origCategories = editableListCategories
        toolbar.editableListCategories = editableListCategories
        print(toolbar)
        newSearchTextField.inputAccessoryView = toolbar
        newSearchTextField.attributedPlaceholder = NSAttributedString(string: "Type here to find...",
                                                                   attributes:
                                                                   [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8784313725, green: 0.878935039, blue: 0.878935039, alpha: 0.75)])

        warningView.alpha = 0
        warningView.layer.cornerRadius = 6
        warningView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        warningLabel.alpha = 0
        warningLabel.text = "Find is paused | Duplicates are not allowed"
        
        
        searchBarLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        cancelButtonNew.layer.cornerRadius = 6
//        autoCompleteButton.layer.cornerRadius = 6
//        newMatchButton.layer.cornerRadius = 6

    }
    
    func removeAllLists() {
        var tempArray = [EditableFindList]()
        for singleList in selectedLists {
//            let indP = IndexPath(item: index, section: 0)
            tempArray.append(singleList)
//            calculateWhereToPlaceComponent(component: singleList, placeInSecondCollectionView: indP)
        }
        
        
        selectedLists.removeAll()
        searchCollectionView.reloadData()
        for temp in tempArray {
            injectListDelegate?.addList(list: temp)
//            calculateWhereToInsert(component: temp)
        }
//        if insertingListsCount == 0 {
//            updateListsLayout(toType: "doneAndShrink")
//        } else {
//            isSchedulingList = true
//        }
        updateListsLayout(toType: "removeListsNow")
        sortSearchTerms()
    }
//    func calculateWhereToInsert(component: EditableFindList) {
//        let componentOrderID = component.orderIdentifier
////        print("calc")
//        var indexPathToAppendTo = 0
//        for (index, singleComponent) in editableListCategories.enumerated() {
//            ///We are going to check if the singleComponent's order identifier is smaller than componentOrderID.
//            ///If it is smaller, we know we must insert the cell ONE to the right of this indexPath.
//            if singleComponent.orderIdentifier < componentOrderID {
//                indexPathToAppendTo = index + 1
//            }
//        }
////        print("index... \(indexPathToAppendTo)")
//        ///Now that we know where to append the green cell, let's do it!
//        editableListCategories.insert(component, at: indexPathToAppendTo)
//        let newIndexPath = IndexPath(item: indexPathToAppendTo, section: 0)
////        listsCollectionView.insertItems(at: [newIndexPath])
//        injectListDelegate?.addList(list: component)
//
//    }
    func updateListsLayout(toType: String) {
        
        switch toType {
        case "onlyTextBox":
            print("onlyText")
            searchShrunk = false
            searchCollectionRightC.constant = 0
            searchBarLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            searchCollectionView.reloadData()
//            darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: false])
            searchTextLeftC.constant = 8
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.newSearchTextField.backgroundColor = UIColor(named: "OpaqueBlur")
//                self.darkBlurEffect.alpha = 0.2
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        case "addListsNow":
            print("pressed a list so now text and lists")
            if searchShrunk == true {
                searchShrunk = false
                searchCollectionRightC.constant = 0
                searchBarLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                searchCollectionView.reloadData()
            }
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: false])
            
            searchTextLeftC.constant = 8
            searchTextTopC.constant = 180
            searchCollectionTopC.constant = 60
            searchContentViewHeight.constant = 243
            
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.searchCollectionView.alpha = 1
                self.arrowDownImage.alpha = 1
                self.textLabel.alpha = 1
                self.listsLabel.alpha = 1
                self.tapToRemoveLabel.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            
        case "removeListsNow":
            print("removed every list so now ONLY TEXT")
            searchTextTopC.constant = 8
            searchCollectionTopC.constant = 8
            searchContentViewHeight.constant = 71
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.searchCollectionView.alpha = 0
                self.textLabel.alpha = 0
                self.listsLabel.alpha = 0
                self.arrowDownImage.alpha = 0
                
                self.tapToRemoveLabel.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        case "prepareForDisplayNew":
            searchTextLeftC.constant = 8
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        case "doneAndShrink":
            print("Done, shrinking lists")
            
//            searchShrunk = true
            searchCollectionView.performBatchUpdates({
                self.searchShrunk = true
            }, completion: { _ in
                self.searchCollectionView.reloadData()
            })
            
//
//
            
//            darkBlurEffectHeightConstraint.constant = 100
//            for j in 0..<searchCollectionView.numberOfItems(inSection: 0) {
//                let indP = IndexPath(item: j, section: 0)
//                if let cell = searchCollectionView.cellForItem(at: indP) as! SearchCell {
//                    cell.labelRigh
//                }
////                collectionView.deselectItem(at: IndexPath(row: j, section: 0), animated: false)
//            }
            
//            var listOfInds = [IndexPath]()
//            for (index, cell) in selectedLists.enumerated() {
//                let indP = IndexPath(item: index, section: 0)
//                listOfInds.append(indP)
//            }
//
//
//            searchCollectionView.reloadData()
//            searchCollectionView.reloadItems(at: <#T##[IndexPath]#>)
            
//            NotificationCenter.default.post(name: .changeSearchListSize, object: nil, userInfo: [0: true])
            switch selectedLists.count {
            case 0:
                print("nothing")
            case 1:
                print("1")
                searchTextLeftC.constant = 71
//                for (index, singleIndex) in selectedLists.enumerated() {
//                    let indP = IndexPath(item: index, section: 0)
//                    let cell = searchCollectionView.cellForItem(at: indP)
//
//                }
            case 2:
                searchTextLeftC.constant = 71 + 55 + 8
            case 3:
                searchTextLeftC.constant = 197
            default:
//                print("default")
                searchTextLeftC.constant = 197
                print("search frame: \(newSearchTextField.frame)")
                let availibleWidth = searchContentView.frame.width - 189
//                layout = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                searchBarLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                searchCollectionRightC.constant = availibleWidth
                print(availibleWidth)
            }
            
            searchContentViewHeight.constant = 71
            searchTextTopC.constant = 8
            searchCollectionTopC.constant = 8
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.newSearchTextField.backgroundColor = UIColor(named: "TransparentBlur")
//                self.darkBlurEffect.alpha = 1
                self.textLabel.alpha = 0
                self.listsLabel.alpha = 0
                self.tapToRemoveLabel.alpha = 0
                self.view.layoutIfNeeded()
            })
        default:
            print("other")
        }
        
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectedLists.count == 0 {
            updateListsLayout(toType: "onlyTextBox")
        } else {
            updateListsLayout(toType: "addListsNow")
        }
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("RETURN END EDIt")
////        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//        
//        
//        
////        })
//        
//        
//    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        finalTextToFind = newSearchTextField.text ?? ""
        view.endEditing(true)
        if insertingListsCount == 0 {
            updateListsLayout(toType: "doneAndShrink")
        } else {
            isSchedulingList = true
        }
//        print("RETURN")
//        print("Text: \(textField.text)")
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            let splits = updatedString.components(separatedBy: "\u{2022}")
            let uniqueSplits = splits.uniques
            if uniqueSplits.count != splits.count {
                print("DUPD UPD UPD UPDU PDPUDP")
                resetFastHighlights()
                allowSearch = false
//                resetFastHighlights()
                shouldResetHighlights = true
                showDuplicateAlert(show: true)
            } else {
                showDuplicateAlert(show: false)
                shouldResetHighlights = false
                allowSearch = true
                finalTextToFind = updatedString
                sortSearchTerms()
            }
         
        }
        
        
        return true
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("CLEAR!!!!")
        finalTextToFind = ""
        allowSearch = true
        shouldResetHighlights = false
        showDuplicateAlert(show: false)
        sortSearchTerms()
        return true
    }
    func showDuplicateAlert(show: Bool) {
        if show == true {
            
            warningHeightC.constant = 32
            UIView.animate(withDuration: 0.5, animations: {
                self.warningView.alpha = 1
                self.warningLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        } else {
            warningHeightC.constant = 6
            UIView.animate(withDuration: 0.5, animations: {
                self.warningView.alpha = 0
                self.warningLabel.alpha = 0
//                self.warningLabel.text = "Find is paused | Duplicates are not allowed"
                self.view.layoutIfNeeded()
            })
        }
    }

    func sortSearchTerms() {
        
        let lowerCaseFinalText = finalTextToFind.lowercased()
        let arrayOfSearch = lowerCaseFinalText.components(separatedBy: "\u{2022}")
//        currentMatchStrings.removeAll()
//        print("matchs aray text field: \(arrayOfMatches)")
        
        var cameAcrossShare = [String]()
        var duplicatedStrings = [String]()
        
        resetFastHighlights()
        currentMatchStrings.removeAll()
        matchToColors.removeAll()
        stringToList.removeAll()
        
        var cameAcrossSearchFieldText = [String]()
        
            print("count: \(selectedLists.count)")
        for list in selectedLists {
            for match in list.contents {
                currentMatchStrings.append(match)
                if !cameAcrossShare.contains(match.lowercased()) {
                    cameAcrossShare.append(match.lowercased())
                } else {
                    duplicatedStrings.append(match)
                }
                
                if arrayOfSearch.contains(match.lowercased()) {
                    cameAcrossSearchFieldText.append(match)
                }
            }
        }
//            print("search array dup: \(cameAcrossSearchFieldText)")
//            print("dup strings: \(duplicatedStrings)")
//            cameAcrossShare = cameAcrossShare.uniques
        duplicatedStrings = duplicatedStrings.uniques
        cameAcrossSearchFieldText = cameAcrossSearchFieldText.uniques
//        duplicatedStrings += cameAcrossSearchFieldText
        
        
//        var refreshedColors = false
        
        for list in selectedLists {
//            print("contents: \(list.contents)")
//            let newList = EditableFindList()
            
//            var tempMatches = [String]()
            for match in list.contents {
                if !duplicatedStrings.contains(match.lowercased()) && !cameAcrossSearchFieldText.contains(match.lowercased()) {
                    
//                    tempMatches.append(match.lowercased())
                    stringToList[match.lowercased()] = list
                    
                } else {
//                    print("NOT")
                    let matchColor = UIColor(hexString: (list.iconColorName)).cgColor
                    
                    
                    if matchToColors[match.lowercased()] == nil {
//                        print("contsdfsdf")
//                        if !matchList.contains(matchColor) {
//                            print("NOT CONT")
                            matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
//                        }
                    } else {
                        if !(matchToColors[match.lowercased()]?.contains(matchColor))! {
                            matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
                        }
                    }
                }
            }
//            if tempMatches.count >= 1 {
////                newList.contents = tempMatches
//                currentMatchStrings += tempMatches
////                for singleM in tempMatches {
////                    stringToIndex[singleM] = index
////                }
//            }
        }
        
//        let lowerCaseFinalText = finalTextToFind.lowercased()
//        var arrayOfMatches = arrayOfSearch
//        var customFindArray = [String]()
        
        let searchList = EditableFindList()
        searchList.descriptionOfList = "Search Array List +0-109028304798614"
        for match in arrayOfSearch {
            stringToList[match] = searchList
        }
        
        let sharedList = EditableFindList()
        sharedList.descriptionOfList = "Shared Lists +0-109028304798614"
        for match in duplicatedStrings {
            stringToList[match] = sharedList
        }
        
        let textShareList = EditableFindList()
        textShareList.descriptionOfList = "Shared Text Lists +0-109028304798614"
        for match in cameAcrossSearchFieldText {
            stringToList[match] = textShareList
        }
        
//
//        for list in currentFindMatches {
//            for cont in list.contents {
//                customFindArray.append(cont)
//                stringToIndex[cont] = 1
//            }
//        }
//        for list in currentListSharedMatches {
//            for cont in list.contents {
//                customFindArray.append(cont)
//                stringToIndex[cont] = 2
//            }
//        }
//        for list in currentSearchListSharedMatches {
//            for cont in list.contents {
//                customFindArray.append(cont)
//                stringToIndex[cont] = 3
//            }
//        }
        
//        arrayOfMatches += customFindArray
        
        currentMatchStrings += arrayOfSearch
        currentMatchStrings = currentMatchStrings.uniques
        //        arrayOfMatches += containedList
        
        print("stringToList:\(stringToList), currentSearchFindListR:\(currentSearchFindList), currentListsSharedFindListR:\(currentListsSharedFindList), currentSearchAndListSharedFindListR:\(currentSearchAndListSharedFindList), currentMatchStringsR:\(currentMatchStrings), matchToColorsR:\(matchToColors)")

        print("Total Match Strings: \(currentMatchStrings)")
        
    }
    func convertToUIImage(buffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
        {
            //let capturedImage = UIImage(cgImage: temporaryImage)
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            print(bufferSize)
            //let deviceRatio = deviceSize.height / deviceSize.width
//            let newWidth = bufferSize.height * deviceRatio
//            let offset = (bufferSize.width - newWidth)
//            let rect = CGRect(x: offset, y: 0, width: newWidth, height: bufferSize.height)
//            let croppedCgImage = temporaryImage.cropping(to: rect)!
            let capturedImage = UIImage(cgImage: temporaryImage, scale: 1.0, orientation: .right)
            return capturedImage
        }
        return nil
    }

    
    
}
extension Notification.Name {
    static let changeSearchListSize = Notification.Name("changeSearchListSize")
}


//extension UIImage {
//    public convenience init?(pixelBuffer: CVPixelBuffer, sceneView: ARSCNView) {
//        var cgImage: CGImage?
//        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
//
//        guard var newCgImage = cgImage else {
//            return nil
//        }
//        let orient = UIApplication.shared.statusBarOrientation
//        let viewportSize = sceneView.bounds.size
//        if let transform = sceneView.session.currentFrame?.displayTransform(for: orient, viewportSize: viewportSize).inverted() {
//            var finalImage = CIImage(cvPixelBuffer: pixelBuffer).transformed(by: transform)
//            guard let buffer = sceneView.session.currentFrame?.capturedImage else { return }
//            let temporaryContext = CIContext(options: nil)
//            if let temporaryImage = temporaryContext.createCGImage(finalImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
//            {
//                newCgImage = temporaryImage
//            }
//        }
//        self.init(cgImage: newCgImage)
//    }
//}

