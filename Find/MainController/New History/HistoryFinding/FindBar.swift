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
import SnapKit


protocol ReturnSortedTerms: class {
    func pause(pause: Bool)
    func returnTerms(matchToColorsR: [String: [CGColor]])
    func startedEditing(start: Bool)
    func pressedReturn()
    func triedToEdit()
    func triedToEditWhilePaused()
    func hereAreCurrentLists(currentSelected: [EditableFindList], currentText: String)
}

//protocol Dis
class FindBar: UIView, UITextFieldDelegate {
    
    let deviceSize = UIScreen.main.bounds.size
    
    var resultsLabel = UILabel()
    
    var origCacheNumber = 0
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var selectedLists = [EditableFindList]()
    
    var highlightColor = "00aeef"
    
    var searchDisabled = false
    
    var dupPaused = false
    
    
    @IBOutlet weak var warningView: UIView!
    
    @IBOutlet weak var warningButton: UIButton!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    var hasExpandedAlert = false
    
    @IBOutlet weak var warningWidth: NSLayoutConstraint!
    
    @IBAction func warningPressed(_ sender: Any) {
        warningWidth.constant = searchField.frame.width
        warningLabel.isHidden = false
        hasExpandedAlert = true
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.warningButton.alpha = 0
                self.layoutIfNeeded()
                
            }
//            self.warningButton.setTitle("Paused", for: .normal)
            self.warningButton.isHidden = true
            self.okButton.isHidden = false
            self.okButton.alpha = 0
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.warningLabel.alpha = 1
                self.okButton.alpha = 1
            }
            
        })
        
    }
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBAction func okButtonPressed(_ sender: Any) {
        hasExpandedAlert = false
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: .calculationModeCubic, animations: {
            self.okButton.isHidden = false
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                self.okButton.alpha = 0
                self.warningLabel.alpha = 0
            }
            self.okButton.isHidden = true
            self.warningLabel.isHidden = true
//            self.warningButton.setTitle("Paused", for: .normal)
            self.warningButton.isHidden = false
            self.warningButton.alpha = 0
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.warningButton.alpha = 1
            }
            
            self.warningWidth.constant = 67
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.layoutIfNeeded()
            }
        })
    }
    
    var finalTextToFind : String = ""
    
        
//    var currentMatchStrings = [String]()
    var matchToColors = [String: [CGColor]]()
    //    var stringToList = [String: EditableFindList]()
    
//    var currentSearchFindList = EditableFindList()
//    var currentListsSharedFindList = EditableFindList()
//    var currentSearchAndListSharedFindList = EditableFindList()
    
    

    @IBOutlet var contentView: FindBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var searchLeftC: NSLayoutConstraint! ///16
    
    @IBOutlet weak var collViewRightC: NSLayoutConstraint!
    //    @IBOutlet weak var collViewWidthC: NSLayoutConstraint!
    ///35
    
    
    var searchActive = false
    
    @IBOutlet weak var searchField: InsetTextField!
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
        
//        _ = self.view
        
//        searchField.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 125)
        
        
        
        Bundle.main.loadNibNamed("FindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        searchField.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//        searchField.clearButtonMode = .whileEditing
        resultsLabel.textAlignment = .right
        loadListsRealm()
        
        
        
        let toolbar = ListToolBar()
        toolbar.frame.size = CGSize(width: deviceSize.width, height: 80)
        toolbar.editableListCategories = editableListCategories
        toolbar.lightMode = true
        injectListDelegate = toolbar
        
        toolbar.pressedButton = self
        toolbar.selectedList = self
        toolbar.startedEditing = self
                
        searchField.inputAccessoryView = toolbar
//        searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "FeedbackGradientLeft")
        
        collectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: "SearchCellid")
        searchField.layer.cornerRadius = 6
        okButton.layer.cornerRadius = 4
        warningView.layer.cornerRadius = 6
        warningLabel.alpha = 0
//        warningView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        warningView.alpha = 0
        warningButton.alpha = 0
        okButton.alpha = 0
        okButton.isHidden = true
        
        searchField.keyboardAppearance = .default
        searchField.autocorrectionType = .no
        searchField.rightView = resultsLabel
        searchField.rightViewMode = .always
        
        resultsLabel.textColor = UIColor.lightGray
        
        
//        searchBar.backgroundColor = .red
        
//        searchBar.layer.cornerRadius = 5
    }

//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
    
    
}

extension FindBar: ChangeFindBar {
    
    
    func change(type: String) {
        switch type {
        case "Disable":
            print("siable")
            DispatchQueue.main.async {
                self.searchField.backgroundColor = UIColor(named: "Gray2")
                self.searchDisabled = true
//                self.he
            }
        case "Enable":
            DispatchQueue.main.async {
                self.searchField.backgroundColor = UIColor(named: "Gray1")
                self.searchDisabled = false
            }
        case "GetLists":
            print("GET LISTS!!!")
            returnTerms?.hereAreCurrentLists(currentSelected: selectedLists, currentText: searchField.text ?? "")
//            self.searchFiel
        default:
            print("WRONGGGG")
            
        }
    }
    
    func giveLists(lists: [EditableFindList], searchText: String) {
        searchDisabled = false
        searchActive = false
        
        searchField.text = searchText
        finalTextToFind = searchText
        
        selectedLists = lists
        var notSelectedLists = [EditableFindList]()
        var selectedOrderIDs = [Int]()
        for list in lists {
            selectedOrderIDs.append(list.orderIdentifier)
        }
        
        for list in editableListCategories {
            if !selectedOrderIDs.contains(list.orderIdentifier) {
                notSelectedLists.append(list)
            }
        }
        print("COUNT:::: NOT::: \(notSelectedLists.count)")
        injectListDelegate?.resetWithLists(lists: notSelectedLists)
        switch selectedLists.count {
        case 0:
            searchLeftC.constant = 12
        case 1:
            searchLeftC.constant = 35 + 3 + 12
        case 2:
            searchLeftC.constant = 73 + 3 + 12
        case 3:
            searchLeftC.constant = 111 + 3 + 12
        default:
            let availibleWidth = contentView.frame.width - 123
            collViewRightC.constant = availibleWidth
            searchLeftC.constant = 111 + 3 + 12
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    
        if hasExpandedAlert == true {
            warningWidth.constant = searchField.frame.size.width
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
        
        collectionView.reloadData()
        
        let splits = searchText.components(separatedBy: "\u{2022}")
        let uniqueSplits = splits.uniques
//            print("up: \(updatedString)")
        if uniqueSplits.count != splits.count {
            dupPaused = true
            returnTerms?.pause(pause: true)
            showDuplicateAlert(show: true)
        } else {
            dupPaused = false
            finalTextToFind = searchText
            showDuplicateAlert(show: false)
            returnTerms?.pause(pause: false)
            sortSearchTerms(shouldReturnTerms: false)
        }
        
    }
    
    
}

extension FindBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SELE")
        if searchDisabled == false {
            print("NOT DIS")
            if searchActive == true {
                print("ACTI")
                let list = selectedLists[indexPath.item]
                selectedLists.remove(object: list)
                collectionView.deleteItems(at: [indexPath])
                injectListDelegate?.addList(list: list)
                
                sortSearchTerms()
                
             switch selectedLists.count {
                case 0:
                    print("nothing")
                    searchLeftC.constant = 12
    //                warningWidth.constant = searchField.frame.size.width - 67
                case 1:
                    print("1")
    //                collViewWidthC.constant = 50
                    searchLeftC.constant = 35 + 3 + 12
    //            warningWidth.constant = searchField.frame.size.width - 67
                case 2:
    //                collViewWidthC.constant = 73
                    searchLeftC.constant = 73 + 3 + 12
                case 3:
    //                collViewWidthC.constant = 111
                    searchLeftC.constant = 111 + 3 + 12
                default:
    //                print("default")
    //                collViewWidthC.constant = 111
                    let availibleWidth = contentView.frame.width - 123
                    //                layout = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                    //            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                    //            searchCollectionRightC.constant = availibleWidth
                                collViewRightC.constant = availibleWidth
                    searchLeftC.constant = 111 + 3 + 12
                }
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                })
            
                if hasExpandedAlert == true {
                    warningWidth.constant = searchField.frame.size.width
                    UIView.animate(withDuration: 0.3, animations: {
                        self.layoutIfNeeded()
                    })
                }
            } else {
                print("FALSE!!")
                searchField.becomeFirstResponder()
            }
        } else {
            returnTerms?.triedToEdit()
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
    
    func showDuplicateAlert(show: Bool) {
        if show == true {

//                warningHeightC.constant = 32
            warningWidth.constant = 67
            self.warningButton.isHidden = false
            
            self.warningLabel.isHidden = true
            self.okButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.warningView.alpha = 1
//                    self.warningLabel.alpha = 1
                self.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.warningButton.alpha = 1
                })
            }
        } else {
//                warningHeightC.constant = 6
            UIView.animate(withDuration: 0.2, animations: {
                self.warningButton.alpha = 0
                self.warningLabel.alpha = 0
                self.okButton.alpha = 0
            }) { _ in
                self.warningButton.isHidden = true
                self.warningLabel.isHidden = true
                self.okButton.isHidden = true
                self.warningWidth.constant = 0
                UIView.animate(withDuration: 0.5, animations: {
                    self.warningView.alpha = 0
//                        self.warningLabel.alpha = 0
    //                self.warningLabel.text = "Find is paused | Duplicates are not allowed"
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        print("clear text: \(textField.text)")
        searchField.text = ""
        dupPaused = false
//        print("setfdfg")
        finalTextToFind = ""
        sortSearchTerms()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchActive = true
        print("ACTIVE")
        returnTerms?.startedEditing(start: true)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if searchDisabled == false {
            return true
        } else {
            returnTerms?.triedToEdit()
            return false
        }
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        searchActive = false
//        print("ENDEDIT")
//        returnTerms?.startedEditing(start: false)
//    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("RETURN?? \(stringToList.count)")
        
        
            if dupPaused == false {
                if matchToColors.keys.count != 0 {
                    searchActive = false
                    textField.resignFirstResponder()
                    returnTerms?.pressedReturn()
                }
            } else {
                returnTerms?.triedToEditWhilePaused()
            }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("CHANGE!! now")
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            let splits = updatedString.components(separatedBy: "\u{2022}")
            let uniqueSplits = splits.uniques
//            print("up: \(updatedString)")
            if uniqueSplits.count != splits.count {
//                print("DUPD UPD UPD UPDU PDPUDP")
//                resetFastHighlights()
//                allowSearch = false
                returnTerms?.pause(pause: true)
                dupPaused = true
                showDuplicateAlert(show: true)
            } else {
                finalTextToFind = updatedString
                showDuplicateAlert(show: false)
//                allowSearch = true
//                finalTextToFind = updatedString
                dupPaused = false
                returnTerms?.pause(pause: false)
                sortSearchTerms()
            }
            
        }
        return true
    }
    
    func buttonPressed(button: ToolbarButtonType) {
        switch button {
        case .removeAll:
            removeAllLists()
        case .newMatch:
//            if let searchText = searchField.text {
//                searchField.text = "\(searchText)\u{2022}"
//            }
            
            if let selectedRange = searchField.selectedTextRange {
                let cursorPosition = searchField.offset(from: searchField.beginningOfDocument, to: selectedRange.start)
                if let textFieldText = searchField.text {
                    var newText = textFieldText
                    newText.insert(string: "\u{2022}", ind: cursorPosition)
                    print("\(cursorPosition)")
                    searchField.text = newText
                    
                    
//                        let positionOriginal = textField.beginningOfDocument
                    if let cursorLocation = searchField.position(from: searchField.beginningOfDocument, offset: cursorPosition + 1) {
                        searchField.selectedTextRange = searchField.textRange(from: cursorLocation, to: cursorLocation)
                    }
                }
            }
        case .done:
            searchActive = false
            print("END   EDIT")
            searchField.resignFirstResponder()
            returnTerms?.startedEditing(start: false)
//            self.endEditing(true)
        }
    }
    func removeAllLists() {
        for temp in selectedLists {
            injectListDelegate?.addList(list: temp)
        }
        selectedLists.removeAll()
        collectionView.reloadData()
//        collViewWidthC.constant = 50
        collViewRightC.constant = 12
        searchLeftC.constant = 12
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
        if hasExpandedAlert == true {
            warningWidth.constant = searchField.frame.size.width
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
        
        sortSearchTerms()
    }
    
    func addList(list: EditableFindList) {
        selectedLists.insert(list, at: 0)
        let indP = IndexPath(item: 0, section: 0)
        collectionView.insertItems(at: [indP])
        switch selectedLists.count {
        case 1:
            searchLeftC.constant = 35 + 3 + 12
        case 2:
            searchLeftC.constant = 73 + 3 + 12
        case 3:
            searchLeftC.constant = 111 + 3 + 12
        default:
            searchLeftC.constant = 111 + 3 + 12
            let availibleWidth = contentView.frame.width - 123
            collViewRightC.constant = availibleWidth
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
        if hasExpandedAlert == true {
            warningWidth.constant = searchField.frame.size.width
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        }
        sortSearchTerms()
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
        for singL in editableListCategories {
            print(singL.name)
        }
        
    }
}


extension FindBar {
    func sortSearchTerms(shouldReturnTerms: Bool = true) {
        if dupPaused == false {
            let lowerCaseFinalText = finalTextToFind.lowercased()
            var arrayOfSearch = lowerCaseFinalText.components(separatedBy: "\u{2022}")
            var cameAcrossShare = [String]()
            var duplicatedStrings = [String]()
            
//            currentMatchStrings.removeAll()
            matchToColors.removeAll()
//            stringToList.removeAll()
            
//            var currentStrings
            var cameAcrossSearchFieldText = [String]()
            for list in selectedLists {
                for match in list.contents {
//                    currentMatchStrings.append(match)
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
            
            print("DUP STRINGA: \(duplicatedStrings)")
            cameAcrossSearchFieldText = cameAcrossSearchFieldText.uniques
            
            print("Search text. \(cameAcrossSearchFieldText)")
            for list in selectedLists {
                for match in list.contents {
                    let matchColor = UIColor(hexString: (list.iconColorName)).cgColor
                    
                    if !duplicatedStrings.contains(match.lowercased()) && !cameAcrossSearchFieldText.contains(match.lowercased()) {
//                        stringToList[match.lowercased()] = list
                        matchToColors[match.lowercased()] = [matchColor]
                    } else {
                        
                        
                        
                        if matchToColors[match.lowercased()] == nil {
                                matchToColors[match.lowercased()] = [matchColor]
    //                        }
                        } else {
                            if !(matchToColors[match.lowercased()]?.contains(matchColor))! {
                                matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
                            }
                        }
                    }
                }
            }
            
    //        print("SEARCH sdsfARR: \(arrayOfSearch)")
            var newSearch = [String]()
            for match in arrayOfSearch {
                if match != "" && !cameAcrossSearchFieldText.contains(match) && !duplicatedStrings.contains(match) {
                    newSearch.append(match)
                }
            }
            arrayOfSearch = newSearch
            
//            let searchList = EditableFindList()
    //        searchList.descriptionOfList = "Search Array List +0-109028304798614"
            for match in arrayOfSearch {
//                stringToList[match] = searchList
                matchToColors[match] = [UIColor(hexString: highlightColor).cgColor]
            }
            
//            let sharedList = EditableFindList()
    //        sharedList.descriptionOfList = "Shared Lists +0-109028304798614"
//            for match in duplicatedStrings {
//                stringToList[match] = sharedList
//            }
            
//            let textShareList = EditableFindList()
    //        textShareList.descriptionOfList = "Shared Text Lists +0-109028304798614"
            for match in cameAcrossSearchFieldText {
//                stringToList[match] = textShareList
                let cgColor = UIColor(hexString: highlightColor).cgColor
                matchToColors[match, default: [CGColor]()].append(cgColor)
            }
//            currentMatchStrings += arrayOfSearch
//            currentMatchStrings = currentMatchStrings.uniques
            
            if shouldReturnTerms {
//                print("GIVE!!!   stringToList:\(stringToList), currentSearchFindListR:\(currentSearchFindList), currentListsSharedFindListR:\(currentListsSharedFindList), currentSearchAndListSharedFindListR:\(currentSearchAndListSharedFindList), currentMatchStringsR:\(currentMatchStrings), matchToColorsR:\(matchToColors)")
                returnTerms?.returnTerms(matchToColorsR: matchToColors)
                    
            }
        }

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
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5))
            
//            make.size.equalTo(CGSize(width: 35, height: 35))
        }
//        self.layoutIfNeeded()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension FindBar: GiveFindbarMatchNumber {
    func howMany(number: Int, inCache: Bool, noSearchTerms: Bool) {
        print("number matches findbar: \(number), no search? \(noSearchTerms) inCache: \(inCache)")
        if noSearchTerms {
            DispatchQueue.main.async {
                self.resultsLabel.text = ""
            }
        } else {
            if inCache {
                origCacheNumber = number
                DispatchQueue.main.async {
                    if number == 0 {
                        self.resultsLabel.text = "No Matches in "
                    } else if number == 1 {
                        self.resultsLabel.text = "1 Match in "
                    } else {
                        self.resultsLabel.text = "\(number) Matches in "
                    }
                    print("mani asynccache: \(number)")
    //                let textH = 35
                    let imageRect = CGRect(x: 0, y: 2.5, width: 30, height: 30)
                    self.resultsLabel.addImageWith(name: "TextFieldCache", behindText: true, bounds: imageRect)
                }
            } else {
                let newNumber = origCacheNumber + number
                print("newNNN ;\(newNumber)")
                DispatchQueue.main.async {
                    if newNumber == 0 {
                        self.resultsLabel.text = "No Matches"
                    } else if newNumber == 1 {
                        self.resultsLabel.text = "1 Match "
                    } else {
                        self.resultsLabel.text = "\(newNumber) Matches"
                    }
                }
            }
        }
//        else {
//            if number == -1 {
//                DispatchQueue.main.async {
//                    if self.origCacheNumber == 0 {
//                        self.resultsLabel.text = "No Matches"
//                    } else if number == 1 {
//                        self.resultsLabel.text = "1 Match "
//                    } else {
//                        self.resultsLabel.text = "\(self.origCacheNumber) Matches"
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    if number == 0 {
//                        self.resultsLabel.text = "No Matches"
//                    } else if number == 1 {
//                        self.resultsLabel.text = "1 Match "
//                    } else {
//                        self.resultsLabel.text = "\(number) Matches"
//                    }
//                }
//            }
//
//        }
    }
}

class InsetTextField: UITextField {
    
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private func setInsets(forBounds bounds: CGRect) -> CGRect {

        var totalInsets = insets //property in you subClass

        if let leftView = leftView  { totalInsets.left += leftView.frame.origin.x }
        if let rightView = rightView { totalInsets.right += rightView.bounds.size.width }

        return bounds.inset(by: totalInsets)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return setInsets(forBounds: bounds)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {

        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= insets.right

        return rect
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {

        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += insets.left

        return rect
    }
}
extension UILabel {

    func addImageWith(name: String, behindText: Bool, bounds: CGRect) {

        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        
        
        attachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        let attachmentString = NSAttributedString(attachment: attachment)

        guard let txt = self.text else {
            return
        }

        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
