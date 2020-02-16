//
//  GeneralViewController.swift
//  Find
//
//  Created by Andrew on 2/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEntryKit

//enum GeneralSpaceError {
//    case hasStartSpace
//    case hasEndSpace
//    case isSingleSpace
//}

protocol GetGeneralInfo: class {
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], interrupt: Bool)
}
//protocol RowChange: class {
//    func tableViewRowCountChanged(rowCount: Int)
//}
class GeneralViewController: UIViewController, ReturnGeneralNow, ReceiveGeneral {
    
    func receiveGeneral(name: String, desc: String, contents: [String]) {
        print("general recieved")
    }
    
    
    
  
    @IBOutlet weak var editButton: UIButton!
    @IBAction func editButtonPressed(_ sender: Any) {
    }
    
    weak var generalDelegate: GetGeneralInfo?

    @IBOutlet var titlesInputView: UIView!
    @IBOutlet var descInputView: UIView!
    @IBOutlet var inputButtonsView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomActionView: UIView!
    //    @IBOutlet weak var contentsContainer: UIView!
//    @IBOutlet weak var contentsTextView: UITextView!
     
    @IBOutlet weak var matchesHeader: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomView: UIView!
    
    //var selectionMode = false
    
    @IBOutlet weak var newMatchButton: UIButton!
    @IBOutlet weak var newMatchPlus: UIButton!
    
    @IBAction func newMatchPressed(_ sender: Any) {
        addNewRow(end: true)
    }
    
    @IBAction func newMatchPlusPressed(_ sender: Any) {
        addNewRow(end: true)
    }
    
    var currentIndexPath = 0
    var addingNewMatch = false
    var emptyStringErrors = [Int]()
    
    var singleSpaceWarning = [Int]()
    var startSpaceWarning = [Int]()
    var endSpaceWarning = [Int]()
    
    var generalSpaces = [String: [Int]]()
    
    var stringToIndexesError = [String: [Int]]()
    
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
  //  weak var rowChanged: RowChange?
    //weak var changedGeneralDelegate: GetGeneralInfo?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    var placeholderLabel : UILabel!
    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = [String]()
    
    func doneWithEditingGeneral(overrideDone: Bool) {
        view.endEditing(true)
        if overrideDone == true {
            print("override!!")
            generalDelegate?.returnNewGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents, interrupt: false)
            SwiftEntryKit.dismiss()
        } else {
           // let textString = contentsTextView.text.removeFirstChars(length: 3)
            //let splits = textString.components(separatedBy: "\n \u{2022} ")
            //print(splits)
//            for cont in contents {
//                if cont == "" {
//                    print("AHKSDGHASKJDHAKJSDHKJASHJKSHDKJHASDJKZHASKJHAKKSDH")
//                    SwiftEntryKitTemplates().displaySEK(message: "Can't create a list with no contents!", backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top)
//                }
//            }
            scrollView.setContentOffset(CGPoint(x: 0, y: currentIndexPath * 50), animated: true)

            checkForErrors(contentsArray: contents)
            if showDoneAlerts() == false {
                print("NO ERRORS!!!!!!++++++++")
            }
            
        }
    }
    func updateInfo() {
        print("update")
        doneWithEditingGeneral(overrideDone: false)
    }
    func highlightRowsOnError() { ///Highlight the rows when done is pressed and there is an error
        print("HIGHLIGHT ROWS, PRESSED DONE")
       // for index in indexPaths {
           // let indexP = IndexPath(row: index, section: 0)
            //tableView.selectRow(at: indexP, animated: false, scrollPosition: .none)
//            print("Single Space: \(singleSpaceWarning)")
//            print("Start Space: \(startSpaceWarning)")
//            print("End Space: \(endSpaceWarning)")
        NotificationCenter.default.post(name: .shouldHighlightRows, object: nil)
//        NotificationCenter.default.post(name: .hasEmptyString, object: [0: emptyStringErrors])
//
//        NotificationCenter.default.post(name: .hasStartSpace, object: [0: startSpaceWarning])
//        NotificationCenter.default.post(name: .hasEndSpace, object: [0: endSpaceWarning])
//        NotificationCenter.default.post(name: .hasSingleSpace, object: [0: singleSpaceWarning])

            //let cell = tableView.cellForRow(at: indexP) as! GeneralTableCell
            //cell.hihilighted = true
       // }
    }
    func showWarningIcon() {
        checkForErrors(contentsArray: contents)
        generalSpaces.removeAll()
//        print("About to show warning icon----------")
//        print("Single Space: \(singleSpaceWarning)")
//        print("Start Space: \(startSpaceWarning)")
//        print("End Space: \(endSpaceWarning)")
        
        for singleSpace in singleSpaceWarning {
            //print("singlespace")
            generalSpaces["Single", default: [Int]()].append(singleSpace)
        }
        for startSpace in startSpaceWarning {
            //print("Startspace")
            generalSpaces["Start", default: [Int]()].append(startSpace)
        }
        for endSpace in endSpaceWarning {
            //print("Endspace")
            generalSpaces["End", default: [Int]()].append(endSpace)
        }
        
       // print("General Spaces: \(generalSpaces)")
        
        NotificationCenter.default.post(name: .hasEmptyString, object: [0: emptyStringErrors])
        
        NotificationCenter.default.post(name: .hasGeneralSpaces, object: nil, userInfo: generalSpaces)
        
//        NotificationCenter.default.post(name: .hasStartSpace, object: [0: startSpaceWarning])
//        NotificationCenter.default.post(name: .hasEndSpace, object: [0: endSpaceWarning])
//        NotificationCenter.default.post(name: .hasSingleSpace, object: [0: singleSpaceWarning])
    }
    
        @IBOutlet weak var descDoneButton: UIButton!
        @IBAction func descButtonDonePressed(_ sender: Any) {
            view.endEditing(true)
            //print("asd")
            //name = titleField.text ?? "Untitled"
        }
        
        @IBOutlet weak var titlesDoneButton: UIButton!
        @IBAction func titlesButtonDonePressed(_ sender: Any) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            view.endEditing(true)
            //descriptionOfList = descriptionField.text
        }
        
        @IBOutlet weak var contentsDoneButton: UIButton!
        @IBAction func contentsDonePressed(_ sender: Any) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            view.endEditing(true)
            //contents = contentsTextView.text
        }
        
        

        
        @IBOutlet weak var helpButton: UIButton!
        @IBAction func helpButtonPressed(_ sender: Any) {
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setUpViews()
            //print(titleField.layer.borderColor)
            
        }
    func addNewRow(end: Bool = false) {
        addingNewMatch = true
        
      //  print("CURR HEIGHT: \(tableView.contentSize.height)")
        let tableViewHeightAfterAddRow = tableView.contentSize.height + 50
        if tableViewHeightAfterAddRow >= 300 {
            tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
            UIView.animate(withDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if end == false { ///User pressed return to insert
          //  print("Return INSERT")
            contents.insert("", at: currentIndexPath + 1)
            currentIndexPath = currentIndexPath + 1
            NotificationCenter.default.post(name: .addedRowAt, object: nil, userInfo: [0: currentIndexPath])
            tableView.insertRows(at: [IndexPath(row: currentIndexPath, section: 0)], with: .automatic)
        } else {
            print("New BUTTON PRESSED")
            
          //  print("contents count \(contents.count)")
            contents.append("")
            currentIndexPath = contents.count - 1
            tableView.insertRows(at: [IndexPath(row: currentIndexPath, section: 0)], with: .automatic)
        }
    }
    func setUpViews() {
        if contents.count == 0 {
            contents.append("")
        }
        
        topView.layer.cornerRadius = 8
        
        titleField.autocapitalizationType = .words
//            contentsContainer.layer.cornerRadius = 12
//           // imageContainer.clipsToBounds = true
//            //imageContainer.layer.cornerRadius = 12
//            contentsTextView.layer.cornerRadius = 6
//
//            contentsTextView.inputAccessoryView = inputButtonsView
        titleField.inputAccessoryView = titlesInputView
        
        descriptionView.inputAccessoryView = descInputView
        descriptionView.layer.cornerRadius = 5.25
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = #colorLiteral(red: 0.9136029482, green: 0.9136029482, blue: 0.9136029482, alpha: 1)
        
        titleField.layer.cornerRadius = 5.25
        titleField.layer.borderColor = #colorLiteral(red: 0.9136029482, green: 0.9136029482, blue: 0.9136029482, alpha: 1)
        titleField.layer.borderWidth = 1
        //titleField.layer.borderWidth = 1
        
        helpButton.layer.cornerRadius = 4
        
        matchesHeader.clipsToBounds = true
        matchesHeader.layer.cornerRadius = 8
        matchesHeader.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
//            tableView.clipsToBounds = true
//            tableView.layer.cornerRadius = 8
//            tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        tableBottomView.layer.cornerRadius = 8
        tableBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bottomActionView.layer.cornerRadius = 8
//            
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = UIImage(systemName: "checkmark.circle")
//
//            let fullString = NSMutableAttributedString(string: "Press the ")
//            fullString.append(NSAttributedString(attachment: imageAttachment))
//            fullString.append(NSAttributedString(string: " button"))
//            //let label.attributedText = fullString
//            
//            newMatchButton.setTitle(fullString, for: .normal)
        
        
        //doneWithListButton.layer.cornerRadius = 4
        descDoneButton.layer.cornerRadius = 4
        titlesDoneButton.layer.cornerRadius = 4
        
        contentsDoneButton.layer.cornerRadius = 4
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Short description"
        placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionView.text.isEmpty
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.isScrollEnabled = false
        
    }
}

extension GeneralViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("aldfshksdfkjh")
        //print("tablevide del \(contents.count)")
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableviewCell") as! GeneralTableCell
        cell.changedTextDelegate = self
        cell.matchTextField.text = contents[indexPath.row]
        //cell.isUserInteractionEnabled = false
//        if indexPath.row
//        cell.shouldShowPlus = true
        if addingNewMatch == true {
            addingNewMatch = false
        cell.matchTextField.becomeFirstResponder()
        }
        cell.indexPath = indexPath.row
        //print("index: \(indexPath.row)")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
}
//protocol NewListMade: class {
//    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String)
//}
extension GeneralViewController: ChangedTextCell {
    
    func cellPressedDoneButton() {
        scrollView.setContentOffset(CGPoint(x: 0, y: currentIndexPath * 50), animated: true)
    }
    
    func textFieldStartedEditing(indexPath: Int) {
        print("curr ind: \(indexPath)")
        currentIndexPath = indexPath
        scrollView.setContentOffset(CGPoint(x: 0, y: (currentIndexPath * 50) + 124), animated: true) ///224 is height of everything above the tableview, so give some edit room so 124

    }
    func textFieldPressedReturn() {
        addNewRow()
    }
    func textFieldChangedText(indexPath: Int, text: String) {
        //print("Changed, text: \(text)")
        contents[indexPath] = text
        showWarningIcon()
    }
    func textFieldEndedEditing(indexPath: Int, text: String) {
        contents[indexPath] = text
        checkForErrors(contentsArray: contents)
        print(contents)
    }
    
}

extension GeneralViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        print("CHANGE")
        if textView.tag == 10902 {
            placeholderLabel.isHidden = !descriptionView.text.isEmpty
        } else if textView.tag == 10903 {
            print("jklds")
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("text FIELD End")
        if textField.tag == 10901 {
            name = titleField.text ?? "Untitled"
            print("sfkh")
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewEnd")
        switch textView.tag {
        case 10902:
            print("end 10902")
            print(descriptionView.text)
            descriptionOfList = descriptionView.text
        case 10903:
            print("end 10903")
//            contents = contentsTextView.text
        default:
            break
        }
        print("END")
    }
    

    func showButtonBarMessage(attributes: EKAttributes, titleMessage: String, desc: String, leftButton: String, yesButton: String, image: String = "WhiteWarningShield") {
        let displayMode = EKAttributes.DisplayMode.inferred
        
        let title = EKProperty.LabelContent(
            text: titleMessage,
            style: .init(
                font: UIFont.systemFont(ofSize: 20, weight: .bold),
                color: .white,
                displayMode: displayMode
            )
        )
        let description = EKProperty.LabelContent(
            text: desc,
            style: .init(
                font: UIFont.systemFont(ofSize: 14, weight: .regular),
                color: .white,
                displayMode: displayMode
            )
        )
        let image = EKProperty.ImageContent(
            imageName: image,
            displayMode: displayMode,
            size: CGSize(width: 35, height: 35),
            contentMode: .scaleAspectFit
        )
        let simpleMessage = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )
        let buttonFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: UIFont.systemFont(ofSize: 20, weight: .bold),
            color: .white,
            displayMode: displayMode
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: yesButton,
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05)) {
                self.highlightRowsOnError()
                SwiftEntryKit.dismiss()
        }
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(#colorLiteral(red: 1, green: 0.9675828359, blue: 0.9005832124, alpha: 1)),
            displayMode: displayMode
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: leftButton,
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05),
            displayMode: displayMode) { [unowned self] in
             print("cool")
                self.doneWithEditingGeneral(overrideDone: true)
                
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: Color.Gray.light,
            buttonHeight: 60,
            displayMode: displayMode,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent
        )
        let contentView = EKAlertMessageView(with: alertMessage)
        contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        contentView.layer.cornerRadius = 10
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
}


extension GeneralViewController {
    func checkForErrors(contentsArray: [String]) {
        emptyStringErrors.removeAll()
        
        ///REFRESH
        singleSpaceWarning.removeAll()
        startSpaceWarning.removeAll()
        endSpaceWarning.removeAll()
        
       
        let noDuplicateArray = contentsArray.uniques
        
        //var hasEmptyMatch = false
        
        print("contentsArray: \(contentsArray)")
        for (index, match) in contentsArray.enumerated() {
            if match == "" {
                //print("empty detected")
              //  hasEmptyMatch = true
                emptyStringErrors.append(index)
            }
        }///First, check for empty string.
        
        
        
       // if hasEmptyMatch == false {
        ///Now, check for duplicates
        stringToIndexesError.removeAll() //
        if contentsArray.count !=  noDuplicateArray.count {
            //print("There are DUPLICATES!!! NoDuplicateArray: \(noDuplicateArray)")
            //let differenceInNumber = contentsArray.count - noDuplicateArray.count
            
            let differentStrings = Array(Set(contentsArray.filter({ (i: String) in contentsArray.filter({ $0 == i }).count > 1}))) ///ContentsArray, but without duplicates
          //  var titleMessage = ""
            //print("diff: \(differentStrings)")
            //REFRESH string to indexes
            var firstOccuranceArray = [String]()
            //firstOccuranceArray.removeAll()
            for (index, singleContent) in contentsArray.enumerated() { ///Go through every match
                if differentStrings.contains(singleContent) {
                    //print("CONTAINTS")
                    //shouldHighlightedRows.append(index)
                    if !firstOccuranceArray.contains(singleContent) {
                        print("doesn't contain \(singleContent)")
                        firstOccuranceArray.append(singleContent)
                    } else { //A occurance has already occured.
                        print("DUPUPUPUPUPUPUP")
                        stringToIndexesError[singleContent, default: [Int]()].append(index)
                    }
                    //print(stringToIndexesError)
                }
            }
        
        } //else { ///No empty matches, or duplicates.
               
        //var hasSingleSpaceMatch = 0
                //var hasStartSpace = 0
                //var hasEndSpace = 0
        
        ///check for empty spaces
        for (index, match) in contentsArray.enumerated() {
            if match == " " {
             //   print("START SINGLE")
                //hasSingleSpaceMatch += 1
                singleSpaceWarning.append(index)
            }
            if match.hasPrefix(" ") {
            //    print("START Prefix")
                //hasStartSpace += 1
                startSpaceWarning.append(index)
            }
            if match.hasSuffix(" ") {
             //   print("START Suffix")
                //hasEndSpace += 1
                endSpaceWarning.append(index)
            }
        }
         //   }
            
       // }
        print("Done checking for errors------------------------------------------------------------------")
        print("Empty: \(emptyStringErrors)")
        print("Single Space: \(singleSpaceWarning)")
        print("Start Space: \(startSpaceWarning)")
        print("End Space: \(endSpaceWarning)")
        print("Duplicates: \(stringToIndexesError)")
    }
    
    
    func showDoneAlerts() -> Bool { ///For the end, done
        //highlightRows()
        var showAnAlert = false
        
        if emptyStringErrors.count >= 1 {
         //   print("MORE THAN 1! \(emptyStringErrors.count)")
            var matchesPlural = "You have \(emptyStringErrors.count) empty matches!"
            if emptyStringErrors.count == 1 { matchesPlural = "Can't have an empty match!" }
            showAnAlert = true
            SwiftEntryKitTemplates().displaySEK(message: matchesPlural, backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top, duration: CGFloat(0.8))
            
            highlightRowsOnError()
        } else if stringToIndexesError.count >= 1 { ///No empty errors. Only duplicates.
     //   print("ELSE!!!!")
            var titleMessage = ""
            
            let dupStrings = stringToIndexesError.keys
            var duplicateStringArray = [String]()
            for dup in dupStrings {
                duplicateStringArray.append(dup)
            }
//            for singleString in dupStrings {
            switch dupStrings.count {
            case 0:
                titleMessage = ""
            case 1:
                if let differentPaths = stringToIndexesError[duplicateStringArray[0]] {
                    var aDuplicate = "a duplicate."
                    //let matchesNumberDiff = (contentsArray.count - noDuplicateArray.count)
                    //let matchesNumberDiff = values.count
           //         print("LKJFSLDFJLSDJFLSDJFSDF  \(differentPaths.count)")
                    if differentPaths.count == 1 {
                        aDuplicate = "a duplicate."
                    } else if differentPaths.count == 2 {
                        aDuplicate = "2 duplicates."
                    } else {
                        aDuplicate = "a couple duplicates."
                    }
                    titleMessage = "\"\(duplicateStringArray[0])\" has \(aDuplicate)"
                }
            case 2:
                titleMessage = "\"\(duplicateStringArray[0])\" and \"\(duplicateStringArray[1])\" have duplicates."
            case 3..<4:
           //     print("ERROR: \(dupStrings.count)")
                var newString = ""
                for (index, message) in duplicateStringArray.enumerated() {
                    if index != duplicateStringArray.count - 1 {
                        newString.append("\"\(message)\", ")
                    } else {
                        newString.append(" and \"\(message)\"")
                    }

             //       print("NEW: \(newString)")
                }
                titleMessage = newString + " have duplicates."
            default:
                titleMessage = "You have a lot of duplicate matches."
            }
           // print("title: \(titleMessage)")
            if titleMessage != "" {
                var attributes = EKAttributes.topFloat
                attributes.displayDuration = .infinity
                attributes.entryInteraction = .absorbTouches
                attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
                attributes.screenInteraction = .absorbTouches

                //var matchesPlural = "You have \(differenceInNumber) empty matches."
                //if differenceInNumber == 1 { matchesPlural = "You have a match that is empty." }
                showAnAlert = true
                showButtonBarMessage(attributes: attributes, titleMessage: titleMessage, desc: "Would you like us to delete the duplicates?", leftButton: "Yes, Delete and save", yesButton: "I'll fix it myself")
            }
        }
        return showAnAlert
    }

    
    func fixDuplicates() {
        
    }
    
}

extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}
extension LosslessStringConvertible {
    var string: String { .init(self) }
}
extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}


extension String {
  func removeFirstChars(length: Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)

        } else {
            return ""
        }
    }
}
struct Color {
    struct BlueGray {
        static let c50 = EKColor(rgb: 0xeceff1)
        static let c100 = EKColor(rgb: 0xcfd8dc)
        static let c300 = EKColor(rgb: 0x90a4ae)
        static let c400 = EKColor(rgb: 0x78909c)
        static let c700 = EKColor(rgb: 0x455a64)
        static let c800 = EKColor(rgb: 0x37474f)
        static let c900 = EKColor(rgb: 0x263238)
    }
    
    struct Netflix {
        static let light = EKColor(rgb: 0x485563)
        static let dark = EKColor(rgb: 0x29323c)
    }
    
    struct Gray {
        static let a800 = EKColor(rgb: 0x424242)
        static let mid = EKColor(rgb: 0x616161)
        static let light = EKColor(red: 230, green: 230, blue: 230)
    }
    
    struct Purple {
        static let a300 = EKColor(rgb: 0xba68c8)
        static let a400 = EKColor(rgb: 0xab47bc)
        static let a700 = EKColor(rgb: 0xaa00ff)
        static let deep = EKColor(rgb: 0x673ab7)
    }
    
    struct BlueGradient {
        static let light = EKColor(red: 100, green: 172, blue: 196)
        static let dark = EKColor(red: 27, green: 47, blue: 144)
    }
    
    struct Yellow {
        static let a700 = EKColor(rgb: 0xffd600)
    }
    
    struct Teal {
        static let a700 = EKColor(rgb: 0x00bfa5)
        static let a600 = EKColor(rgb: 0x00897b)
    }
    
    struct Orange {
        static let a50 = EKColor(rgb: 0xfff3e0)
    }
    
    struct LightBlue {
        static let a700 = EKColor(rgb: 0x0091ea)
    }
    
    struct LightPink {
        static let first = EKColor(rgb: 0xff9a9e)
        static let last = EKColor(rgb: 0xfad0c4)
    }
}
extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
