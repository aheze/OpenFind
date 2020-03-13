//
//  FindBar.swift
//  Find
//
//  Created by Zheng on 3/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RealmSwift


protocol ReturnSortedTerms: class {
    func returnTerms(stringToListR: [String: EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String: [CGColor]])
}
class FindBar: UIView, UITextFieldDelegate {
    
    let deviceSize = UIScreen.main.bounds.size
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var selectedLists = [EditableFindList]()
    
    
    var finalTextToFind : String = ""
    var matchToColors = [String: [CGColor]]()
        
    var currentMatchStrings = [String]()
    
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var stringToList = [String: EditableFindList]()

    @IBOutlet var contentView: FindBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var searchLeftC: NSLayoutConstraint! ///16
    
    @IBOutlet weak var collViewRightC: NSLayoutConstraint!
    //    @IBOutlet weak var collViewWidthC: NSLayoutConstraint!
    ///35
    
    
    var searchActive = false
    
    @IBOutlet weak var searchField: TextField!
    //    @IBOutlet weak var searchBar: UISearchBar!
    
    weak var injectListDelegate: InjectLists?
    weak var returnTerms: ReturnSortedTerms?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
       // fromNib()
        //self.changeNumberDelegate = self
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        
        
        Bundle.main.loadNibNamed("FindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        searchBar.searchTextField.backgroundColor = .red
//        searchBar.searchTextField.backgroundColor = UIColor(named: "Gray1")
////        searchBar.tintColor = .red
//        searchBar.barTintColor = UIColor(named: "Gray3")
//        searchBar.layer.borderWidth = 1
//        searchBar.layer.borderColor = UIColor(named: "Gray3")?.cgColor
        
        loadListsRealm()
        
        let toolbar = ListToolBar()
        toolbar.frame.size = CGSize(width: deviceSize.width, height: 80)
        toolbar.editableListCategories = editableListCategories
        injectListDelegate = toolbar
        
        toolbar.pressedButton = self
        toolbar.selectedList = self
        toolbar.startedEditing = self
                
        searchField.inputAccessoryView = toolbar
//        searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "FeedbackGradientLeft")
        
        collectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: "SearchCellid")
        searchField.layer.cornerRadius = 6
        
        
//        searchBar.backgroundColor = .red
        
//        searchBar.layer.cornerRadius = 5
    }

//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
    
    
}

extension FindBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchActive == true {
            let list = selectedLists[indexPath.item]
            selectedLists.remove(object: list)
            collectionView.deleteItems(at: [indexPath])
            injectListDelegate?.addList(list: list)
            
         switch selectedLists.count {
            case 0:
                print("nothing")
                searchLeftC.constant = 16
            case 1:
                print("1")
//                collViewWidthC.constant = 50
                searchLeftC.constant = 35 + 3 + 16
            case 2:
//                collViewWidthC.constant = 73
                searchLeftC.constant = 73 + 3 + 16
            case 3:
//                collViewWidthC.constant = 111
                searchLeftC.constant = 111 + 3 + 16
            default:
                print("default")
//                collViewWidthC.constant = 111
                let availibleWidth = contentView.frame.width - 127
                //                layout = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                //            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                //            searchCollectionRightC.constant = availibleWidth
                            collViewRightC.constant = availibleWidth
                searchLeftC.constant = 111 + 3 + 16
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        } else {
            searchField.becomeFirstResponder()
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCellid", for: indexPath) as! SearchCollectionCell
        
        let list = selectedLists[indexPath.item]
        
        
//        let newImage = UIImage(systemName: list.iconImageName)?.withTintColor(UIColor.white)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        let backgroundColor = UIColor(hexString: list.iconColorName)
        
        cell.contentView.backgroundColor = backgroundColor
//        let image = UIImage(
        cell.imageView.image = newImage
        cell.layer.cornerRadius = 6
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.height
        print("WIDTH:::\(width)")
        return CGSize(width: width, height: width)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        print("SIXEJOJSDLDSFDLF")
//        return CGFloat(3)
//    }
    
    
}

extension FindBar: ToolbarButtonPressed, SelectedList, StartedEditing {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchActive = true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchActive = false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            let splits = updatedString.components(separatedBy: "\u{2022}")
            let uniqueSplits = splits.uniques
            if uniqueSplits.count != splits.count {
//                print("DUPD UPD UPD UPDU PDPUDP")
//                resetFastHighlights()
//                allowSearch = false
//                showDuplicateAlert(show: true)
            } else {
                finalTextToFind = updatedString
//                showDuplicateAlert(show: false)
//                allowSearch = true
//                finalTextToFind = updatedString
//                sortSearchTerms()
            }
            
        }
        return true
    }
    
    func buttonPressed(button: ToolbarButtonType) {
        switch button {
        case .removeAll:
            removeAllLists()
        case .newMatch:
            if let searchText = searchField.text {
                searchField.text = "\(searchText)\u{2022}"
            }
        case .done:
            self.endEditing(true)
        }
    }
    func removeAllLists() {
//        searchBar.searchTextField.tokens = []
//        var tempArray = [EditableFindList]()
//        for singleList in selectedLists {
////            let indP = IndexPath(item: index, section: 0)
//            tempArray.append(singleList)
////            calculateWhereToPlaceComponent(component: singleList, placeInSecondCollectionView: indP)
//        }
//
//
//        selectedLists.removeAll()
////        searchCollectionView.reloadData()
        for temp in selectedLists {
            injectListDelegate?.addList(list: temp)
//            calculateWhereToInsert(component: temp)
        }
        selectedLists.removeAll()
        collectionView.reloadData()
//        collViewWidthC.constant = 50
        collViewRightC.constant = 16
        searchLeftC.constant = 16
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
//        print("remove")
    }
    
    func addList(list: EditableFindList) {
//        let insertPosition = selectedLists.count
//        selectedLists.append(list)
        selectedLists.insert(list, at: 0)
        let indP = IndexPath(item: 0, section: 0)
        collectionView.insertItems(at: [indP])
        
//        let newImage = UIImage(systemName: list.iconImageName)?.withTintColor(UIColor(hexString: list.iconColorName))
//        let newToken = UISearchToken(icon: newImage, text: list.name)
        
        switch selectedLists.count {
        case 0:
            print("nothing")
        case 1:
            print("1")
//            collViewWidthC.constant = 50
            searchLeftC.constant = 35 + 3 + 16
//                for (index, singleIndex) in selectedLists.enumerated() {
//                    let indP = IndexPath(item: index, section: 0)
//                    let cell = searchCollectionView.cellForItem(at: indP)
//
//                }
        case 2:
//            collViewWidthC.constant = 73
            searchLeftC.constant = 73 + 3 + 16
        case 3:
//            collViewWidthC.constant = 111
            searchLeftC.constant = 111 + 3 + 16
        default:
            print("default")
//            collViewWidthC.constant = 111
            searchLeftC.constant = 111 + 3 + 16
            
            print("search frame: \(searchField.frame)")
            let availibleWidth = contentView.frame.width - 127
//                layout = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//            searchCollectionRightC.constant = availibleWidth
            collViewRightC.constant = availibleWidth
//            print(availibleWidth)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
//
//        newToken.representedObject = list
////        purchasesToken.c
//
//        searchBar.searchTextField.insertToken(newToken, at: insertPosition)
//        if selectedLists.count <= 1 {
//            updateListsLayout(toType: "addListsNow")
//        }
    
//        let indexP = IndexPath(item: 0, section: 0)
//        searchCollectionView.performBatchUpdates({
//            print("add3")
//            self.searchCollectionView.insertItems(at: [indexP])
//            self.insertingListsCount += 1
//        }, completion: { _ in
//            self.insertingListsCount -= 1
//            if self.isSchedulingList == true {
//                if self.insertingListsCount == 0 {
//                    self.isSchedulingList = false
//                    self.updateListsLayout(toType: "doneAndShrink")
//                }
//            }
//        })
        
//        sortSearchTerms()
    }
    
    func startedEditing(start: Bool) {
        print("started editing")
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
        for singL in editableListCategories {
            print(singL.name)
        }
        
//        searchCollectionView.reloadData()
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        print("Change123123, \(searchText)")
//        var tokenLists = [EditableFindList]()
//
//        searchBar.searchTextField.tokens.forEach {
//            if let list = $0.representedObject as? EditableFindList {
////                print(list.name)
////                if !selectedLists.contains(list) {
//                    tokenLists.append(list)
////                }
//            }
//        }
////        selectedLists = tokenLists
//        var tempLists = [EditableFindList]()
//        for list in selectedLists {
//            if !tokenLists.contains(list) {
//                tempLists.append(list)
//            }
//
//
////            print("del list: \(tempLi.name)")
//        }
//        for list in tempLists {
//            injectListDelegate?.addList(list: list)
//        }
//        tempLists.forEach { list in
////            print("DELELE: \(list.name)")
//            selectedLists.remove(object: list)
//        }
////        let tokens = searchBar.searchTextField.tokens
//    }

}


extension FindBar {
    func sortSearchTerms() {
        let lowerCaseFinalText = finalTextToFind.lowercased()
        let arrayOfSearch = lowerCaseFinalText.components(separatedBy: "\u{2022}")
        var cameAcrossShare = [String]()
        var duplicatedStrings = [String]()
        
        currentMatchStrings.removeAll()
        matchToColors.removeAll()
        
        var cameAcrossSearchFieldText = [String]()
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
        duplicatedStrings = duplicatedStrings.uniques
        cameAcrossSearchFieldText = cameAcrossSearchFieldText.uniques
        for list in selectedLists {
            for match in list.contents {
                if !duplicatedStrings.contains(match.lowercased()) && !cameAcrossSearchFieldText.contains(match.lowercased()) {
                    stringToList[match.lowercased()] = list
                } else {
                    let matchColor = UIColor(hexString: (list.iconColorName)).cgColor
                    if matchToColors[match.lowercased()] == nil {
                            matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
//                        }
                    } else {
                        if !(matchToColors[match.lowercased()]?.contains(matchColor))! {
                            matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
                        }
                    }
                }
            }
        }
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
    currentMatchStrings += arrayOfSearch
    currentMatchStrings = currentMatchStrings.uniques
    returnTerms?.returnTerms(stringToListR: stringToList, currentSearchFindListR: currentSearchFindList, currentListsSharedFindListR: currentListsSharedFindList, currentSearchAndListSharedFindListR: currentSearchAndListSharedFindList, currentMatchStringsR: currentMatchStrings, matchToColorsR: matchToColors)

    }
}


class SearchCollectionCell: UICollectionViewCell {

    var imageView: UIImageView = UIImageView(frame: CGRect.zero)

    
    override init(frame : CGRect) {
        super.init(frame : frame)
        imageView.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        imageView.contentMode = .scaleAspectFit
//        imageView.textAlignment = .center
        contentView.addSubview(imageView)
//        print("frameSize: \(frame)")
//        imageView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//            make.size.equalTo(CGSize(width: 35, height: 35))
//        }
//        self.layoutIfNeeded()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


