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


protocol FindBarDelegate: class {
    func pause(pause: Bool)
    func returnTerms(matchToColorsR: [String: [CGColor]])
    func startedEditing(start: Bool)
    func pressedReturn()
    func triedToEdit()
    func triedToEditWhilePaused()
//    func hereAreCurrentLists(currentSelected: [EditableFindList], currentText: String, object: MatchesLabelObject)
}

class FindBar: UIView, UITextFieldDelegate {
    
    let deviceSize = screenBounds.size
    
    var resultsLabel = UILabel()
    
    var origCacheNumber = 0
    var totalResultsNumber = 0
    var searchingOnlyInCache = true
    
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
    var matchToColors = [String: [CGColor]]()
    
    @IBOutlet var contentView: FindBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchLeftC: NSLayoutConstraint! ///16
    @IBOutlet weak var collViewRightC: NSLayoutConstraint!
    //    @IBOutlet weak var collViewWidthC: NSLayoutConstraint!
    ///35
    
    
    var searchActive = false
    
    @IBOutlet weak var searchField: InsetTextField!
    
    weak var injectListDelegate: InjectLists?
    weak var findBarDelegate: FindBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    private func setup() {
        
        clipsToBounds = true
        layer.cornerRadius = 5
        
        Bundle.main.loadNibNamed("FindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        searchField.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        resultsLabel.textAlignment = .right
        
        resultsLabel.text = "                                   "
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
        
        collectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: "SearchCellid")
        searchField.layer.cornerRadius = 6
        okButton.layer.cornerRadius = 4
        warningView.layer.cornerRadius = 6
        warningLabel.alpha = 0
        
        warningView.alpha = 0
        warningButton.alpha = 0
        okButton.alpha = 0
        okButton.isHidden = true
        
        searchField.keyboardAppearance = .default
        searchField.autocorrectionType = .no
        searchField.rightView = resultsLabel
        searchField.rightViewMode = .always
        searchField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        searchField.attributedPlaceholder = NSAttributedString(string: "Type here to find", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.75)])
        
        resultsLabel.textColor = UIColor.lightGray

    }
}



extension FindBar {
    
    func disableTextField(_ shouldDisable: Bool) {
        if shouldDisable {
            self.searchField.backgroundColor = UIColor(named: "Gray2")
            self.searchDisabled = true
        } else {
            self.searchField.backgroundColor = UIColor(named: "Gray1")
            self.searchDisabled = false
        }
    }
    
    
//    func change(type: String) {
//        switch type {
//        case "Disable":
//            DispatchQueue.main.async {
//                self.searchField.backgroundColor = UIColor(named: "Gray2")
//                self.searchDisabled = true
//            }
//        case "Enable":
//            DispatchQueue.main.async {
//                self.searchField.backgroundColor = UIColor(named: "Gray1")
//                self.searchDisabled = false
//            }
//        case "GetLists":
//            let currentLabelObject = MatchesLabelObject()
//            currentLabelObject.cachedNumber = origCacheNumber
//            currentLabelObject.totalNumber = totalResultsNumber
//            currentLabelObject.hadSearchedInCache = searchingOnlyInCache
////            print("Orig cache number: \(origCacheNumber), total: \(totalResultsNumber), onlyInCache? \(searchingOnlyInCache)")
//            returnTerms?.hereAreCurrentLists(currentSelected: selectedLists, currentText: searchField.text ?? "", object: currentLabelObject)
////            self.searchFiel
//        default:
//            print("WRONGGGG")
//
//        }
//    }
    
//    func giveLists(lists: [EditableFindList], searchText: String, labelObject: MatchesLabelObject) {
//
//        origCacheNumber = labelObject.cachedNumber
//        totalResultsNumber = labelObject.totalNumber
//        if labelObject.hadSearchedInCache {
//            setResultLabelText(searchingInCache: true, number: totalResultsNumber)
////            if totalResultsNumber == 0 {
////                let noMatchesInSpace = NSLocalizedString("noMatchesInSpace", comment: "FindBar def=No Matches in ")
//////                resultsLabel.text = "No Matches in "
////                resultsLabel.text = noMatchesInSpace
////            } else if totalResultsNumber == 1 {
//////                resultsLabel.text = "1 Match in "
////                resultsLabel.text = oneMatchInSpace
////            } else {
////
////                let xMatchesInSpace = NSLocalizedString("%d MatchesInSpace", comment: "FindBar def=x Matches in ")
////                let string = String.localizedStringWithFormat(xMatchesInSpace, totalResultsNumber)
//////                resultsLabel.text = "\(totalResultsNumber) Matches in "
////                resultsLabel.text = string
////            }
////
////            let imageRect = CGRect(x: 0, y: 2.5, width: 30, height: 30)
////            resultsLabel.addImageWith(name: "TextFieldCache", behindText: true, bounds: imageRect)
//        } else {
//            setResultLabelText(searchingInCache: false, number: totalResultsNumber)
////            if totalResultsNumber == 0 {
////
////                let noMatches = NSLocalizedString("noMatches", comment: "FindBar def=No Matches")
////                self.resultsLabel.text = noMatches
////            } else if totalResultsNumber == 1 {
////
////                self.resultsLabel.text = oneMatch
////            } else {
////                let matches = NSLocalizedString("matches", comment: "FindBar def=Matches")
////                self.resultsLabel.text = "\(totalResultsNumber) \(matches)"
////            }
//        }
//
//        searchDisabled = false
//        searchActive = false
//
//        searchField.text = searchText
//        finalTextToFind = searchText
//
//        selectedLists = lists
//        var notSelectedLists = [EditableFindList]()
//        var selectedOrderIDs = [Int]()
//        for list in lists {
//            selectedOrderIDs.append(list.orderIdentifier)
//        }
//
//        for list in editableListCategories {
//            if !selectedOrderIDs.contains(list.orderIdentifier) {
//                notSelectedLists.append(list)
//            }
//        }
//
//        injectListDelegate?.resetWithLists(lists: notSelectedLists)
//        switch selectedLists.count {
//        case 0:
//            searchLeftC.constant = 0
//        case 1:
//            searchLeftC.constant = 35 + 3
//        case 2:
//            searchLeftC.constant = 73 + 3
//        case 3:
//            searchLeftC.constant = 111 + 3
//        default:
//            let availableWidth = contentView.frame.width - 123
//            collViewRightC.constant = availableWidth
//            searchLeftC.constant = 111 + 3
//        }
//
////        UIView.animate(withDuration: 0.3, animations: {
//            self.layoutIfNeeded()
////        })
//
//        if hasExpandedAlert == true {
//            warningWidth.constant = searchField.frame.size.width
//            UIView.animate(withDuration: 0.3, animations: {
//                self.layoutIfNeeded()
//            })
//        }
//
//        collectionView.reloadData()
//
//        let splits = searchText.components(separatedBy: "\u{2022}")
//        let uniqueSplits = splits.uniques
//        if uniqueSplits.count != splits.count {
//            dupPaused = true
//            returnTerms?.pause(pause: true)
//            showDuplicateAlert(show: true)
//        } else {
//            dupPaused = false
//            finalTextToFind = searchText
//            showDuplicateAlert(show: false)
//            returnTerms?.pause(pause: false)
//            sortSearchTerms(shouldReturnTerms: false)
//        }
//
//    }
    
    
}

extension FindBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchDisabled == false {
            if searchActive == true {
                let list = selectedLists[indexPath.item]
                selectedLists.remove(object: list)
                collectionView.deleteItems(at: [indexPath])
                injectListDelegate?.addList(list: list)
                
                sortSearchTerms()
                
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
                    let availableWidth = contentView.frame.width - 123
                    collViewRightC.constant = availableWidth
                    searchLeftC.constant = 111 + 3
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
                searchField.becomeFirstResponder()
            }
        } else {
            findBarDelegate?.triedToEdit()
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCellid", for: indexPath) as! SearchCollectionCell
        
        let list = selectedLists[indexPath.item]
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        let backgroundColor = UIColor(hexString: list.iconColorName)
        
        cell.contentView.backgroundColor = backgroundColor
        cell.imageView.image = newImage
        cell.layer.cornerRadius = 6
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.height
        return CGSize(width: width, height: width)
    }
    
}

extension FindBar: ToolbarButtonPressed, SelectedList, StartedEditing {
    
    func showDuplicateAlert(show: Bool) {
        if show == true {

            warningWidth.constant = 67
            self.warningButton.isHidden = false
            
            self.warningLabel.isHidden = true
            self.okButton.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.warningView.alpha = 1
                self.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.warningButton.alpha = 1
                })
            }
        } else {
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
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearTextField()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchActive = true
        findBarDelegate?.startedEditing(start: true)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if searchDisabled == false {
            return true
        } else {
            findBarDelegate?.triedToEdit()
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
            if dupPaused == false {
                if matchToColors.keys.count != 0 {
                    searchActive = false
                    textField.resignFirstResponder()
                    findBarDelegate?.pressedReturn()
                }
            } else {
                findBarDelegate?.triedToEditWhilePaused()
            }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            let splits = updatedString.components(separatedBy: "\u{2022}")
            let uniqueSplits = splits.uniques
            if uniqueSplits.count != splits.count {
                findBarDelegate?.pause(pause: true)
                dupPaused = true
                showDuplicateAlert(show: true)
            } else {
                finalTextToFind = updatedString
                showDuplicateAlert(show: false)
                dupPaused = false
                findBarDelegate?.pause(pause: false)
                sortSearchTerms()
            }
            
        }
        return true
    }
    
    func clearTextField() {
        searchField.text = ""
        dupPaused = false
        finalTextToFind = ""
        sortSearchTerms()
    }
    
    func buttonPressed(button: ToolbarButtonType) {
        switch button {
        case .removeAll:
            removeAllLists()
        case .newMatch:
            if let selectedRange = searchField.selectedTextRange {
                let cursorPosition = searchField.offset(from: searchField.beginningOfDocument, to: selectedRange.start)
                if let textFieldText = searchField.text {
                    var newText = textFieldText
                    newText.insert(string: "\u{2022}", ind: cursorPosition)
                    
                    searchField.text = newText
                    
                    if let cursorLocation = searchField.position(from: searchField.beginningOfDocument, offset: cursorPosition + 1) {
                        searchField.selectedTextRange = searchField.textRange(from: cursorLocation, to: cursorLocation)
                    }
                }
            }
        case .done:
            searchActive = false
            searchField.resignFirstResponder()
            findBarDelegate?.startedEditing(start: false)
        }
    }
    func removeAllLists() {
        for temp in selectedLists {
            injectListDelegate?.addList(list: temp)
        }
        selectedLists.removeAll()
        collectionView.reloadData()
        collViewRightC.constant = 0
        searchLeftC.constant = 0
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
        if var cats = listCategories {
            cats = cats.sorted(byKeyPath: "dateCreated", ascending: false)
            listCategories = cats
            for (index, singleL) in cats.enumerated() {
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
    }

}


extension FindBar {
    func sortSearchTerms(shouldReturnTerms: Bool = true) {
        if dupPaused == false {
            let lowerCaseFinalText = finalTextToFind.lowercased()
            var arrayOfSearch = lowerCaseFinalText.components(separatedBy: "\u{2022}")
            var cameAcrossShare = [String]()
            var duplicatedStrings = [String]()
            
            matchToColors.removeAll()
            
            var cameAcrossSearchFieldText = [String]()
            for list in selectedLists {
                for match in list.contents {
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
                    let matchColor = UIColor(hexString: (list.iconColorName)).cgColor
                    
                    if !duplicatedStrings.contains(match.lowercased()) && !cameAcrossSearchFieldText.contains(match.lowercased()) {
                        matchToColors[match.lowercased()] = [matchColor]
                    } else {
                        
                        
                        if matchToColors[match.lowercased()] == nil {
                                matchToColors[match.lowercased()] = [matchColor]
                        } else {
                            if !(matchToColors[match.lowercased()]?.contains(matchColor))! {
                                matchToColors[match.lowercased(), default: [CGColor]()].append(matchColor)
                            }
                        }
                    }
                }
            }
            
            var newSearch = [String]()
            for match in arrayOfSearch {
                if match != "" && !cameAcrossSearchFieldText.contains(match) && !duplicatedStrings.contains(match) {
                    newSearch.append(match)
                }
            }
            arrayOfSearch = newSearch
            
            for match in arrayOfSearch {
                matchToColors[match] = [UIColor(hexString: highlightColor).cgColor]
            }
           
            for match in cameAcrossSearchFieldText {
                let cgColor = UIColor(hexString: highlightColor).cgColor
                matchToColors[match, default: [CGColor]()].append(cgColor)
            }
            
            if shouldReturnTerms {
                findBarDelegate?.returnTerms(matchToColorsR: matchToColors)
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
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5))
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//extension FindBar: GiveFindbarMatchNumber {
//    func howMany(number: Int, inCache: Bool, noSearchTerms: Bool) {
//        DispatchQueue.main.async {
//            if noSearchTerms {
//                self.totalResultsNumber = 0
//                self.origCacheNumber = 0
//                self.searchingOnlyInCache = true
//                self.resultsLabel.text = "                                   "
//            } else {
//                if inCache {
//                    self.origCacheNumber = number
//                    self.totalResultsNumber = number
//                    self.searchingOnlyInCache = true
////                    if number == 0 {
////                        self.resultsLabel.text = "No Matches in "
////                    } else if number == 1 {
////                        self.resultsLabel.text = "1 Match in "
////                    } else {
////                        self.resultsLabel.text = "\(number) Matches in "
////                    }
//////                    print("mani asynccache: \(number)")
////    //                let textH = 35
////                    let imageRect = CGRect(x: 0, y: 2.5, width: 30, height: 30)
////                    self.resultsLabel.addImageWith(name: "TextFieldCache", behindText: true, bounds: imageRect)
//                    self.setResultLabelText(searchingInCache: true, number: number)
//                } else {
//                    let newNumber = self.origCacheNumber + number
//                    self.searchingOnlyInCache = false
//                    self.totalResultsNumber = newNumber
////                    print("newNNN ;\(newNumber)")
//                    self.setResultLabelText(searchingInCache: false, number: newNumber)
////                    if newNumber == 0 {
////
////                        let noMatches = NSLocalizedString("noMatches", comment: "FindBar def=No Matches")
////                        self.resultsLabel.text = noMatches
////                    } else if totalResultsNumber == 1 {
////
////                        self.resultsLabel.text = oneMatch
////                    } else {
////                        let matches = NSLocalizedString("matches", comment: "FindBar def=Matches")
////                        self.resultsLabel.text = "\(newNumber) \(matches)"
////                    }
////                    if newNumber == 0 {
////                        self.resultsLabel.text = "No Matches"
////                    } else if newNumber == 1 {
////                        self.resultsLabel.text = "1 Match "
////                    } else {
////                        self.resultsLabel.text = "\(newNumber) Matches"
////                    }
//                }
//            }
//        }
//    }
//}

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

extension FindBar {
    func setResultLabelText(searchingInCache: Bool, number: Int) {
        if searchingInCache {
            if number == 0 {
                let noMatchesInSpace = NSLocalizedString("noMatchesInSpace", comment: "FindBar def=No Matches in ")
                //                resultsLabel.text = "No Matches in "
                resultsLabel.text = noMatchesInSpace
            } else if totalResultsNumber == 1 {
                let oneMatchInSpace = NSLocalizedString("oneMatchInSpace", comment: "FindBar def=1 Match in ")
                //                resultsLabel.text = "1 Match in "
                resultsLabel.text = oneMatchInSpace
            } else {
                
                let xMatchesInSpace = NSLocalizedString("%d MatchesInSpace", comment: "FindBar def=x Matches in ")
                let string = String.localizedStringWithFormat(xMatchesInSpace, number)
                //                resultsLabel.text = "\(totalResultsNumber) Matches in "
                resultsLabel.text = string
            }
            
            let imageRect = CGRect(x: 0, y: 2.5, width: 30, height: 30)
            resultsLabel.addImageWith(name: "TextFieldCache", behindText: true, bounds: imageRect)
        } else {
            
            if number == 0 {
                
                let noMatches = NSLocalizedString("noMatches", comment: "FindBar def=No Matches")
                self.resultsLabel.text = noMatches
            } else if totalResultsNumber == 1 {
                
                let oneMatch = NSLocalizedString("oneMatch", comment: "Multifile def=1 match")
                self.resultsLabel.text = oneMatch
            } else {
                let matches = NSLocalizedString("matches", comment: "FindBar def=Matches")
                self.resultsLabel.text = "\(number) \(matches)"
            }
        }
    }
}
