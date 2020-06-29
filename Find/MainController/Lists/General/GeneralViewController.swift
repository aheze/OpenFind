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
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: [String], hasErrors: Bool, overrideMake: Bool)
}
protocol DeleteList: class {
    func deleteList()
}
class GeneralViewController: UIViewController, ReturnGeneralNow, ReceiveGeneral {
    
    func receiveGeneral(nameOfList: String, desc: String, contentsOfList: [String]) {
        print("general recieved")
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
    }
    
    var isEditingText = false
    
    weak var generalDelegate: GetGeneralInfo?

    @IBOutlet var titlesInputView: UIView!
    @IBOutlet var descInputView: UIView!
    @IBOutlet var inputButtonsView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var matchesHeader: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableBottomView: UIView!
    
    
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
    
    var shouldHighlightRows = false
    
    
    var generalSpaces = [String: [Int]]()
    
    var stringToIndexesError = [String: [Int]]() ///A dictionary of the DUPLICATE rows- not the first occurance. These rows should be deleted.
    
    weak var deleteTheList: DeleteList?
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    var placeholderLabel : UILabel!
    
    var name = ""
    var descriptionOfList = ""
    var contents = [String]()
    
    func doneWithEditingGeneral(overrideDone: Bool) {
        view.endEditing(true)
        var newName = name
        var newDesc = descriptionOfList
        
        let untitledName = NSLocalizedString("untitledName", comment: "GeneralViewController def=Untitled")
        let noDescription = NSLocalizedString("noDescription", comment: "GeneralViewController def=No Description")
        if newName == "" { newName = untitledName }
        if newDesc == "" { newDesc = noDescription }
        
        if overrideDone == true {
            generalDelegate?.returnNewGeneral(nameOfList: newName, desc: newDesc, contentsOfList: contents, hasErrors: false, overrideMake: true)
            SwiftEntryKit.dismiss()
        } else {
            let origPoint = CGPoint(x: 0, y: (currentIndexPath * 50) + 500)
                let rect = CGRect(origin: origPoint, size: CGSize(width: 50, height: 50))
                scrollView.scrollRectToVisible(rect, animated: true)

            checkForErrors(contentsArray: contents)
            if showDoneAlerts() == false {
                print("NO ERRORS!!!!!!++++++++")
                generalDelegate?.returnNewGeneral(nameOfList: newName, desc: newDesc, contentsOfList: contents, hasErrors: false, overrideMake: false)
            } else {
                generalDelegate?.returnNewGeneral(nameOfList: newName, desc: newDesc, contentsOfList: contents, hasErrors: true, overrideMake: false)
            }
            
        }
    }
    func updateInfo() {
        doneWithEditingGeneral(overrideDone: false)
    }

    func highlightRowsOnError(type: String) { ///Highlight the rows when done is pressed and there is an error
        print("HIGHLIGHT ROWS, PRESSED DONE")
        
        switch type {
        case "EmptyMatch":
            var reloadPaths = [IndexPath]()
            for ind in emptyStringErrors {
                let indPath = IndexPath(row: ind, section: 0)
                
                if let cell = tableView.cellForRow(at: indPath) as? GeneralTableCell {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.overlayView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                        cell.animateDupSlide()
                    })
                } else {
                    reloadPaths.append(indPath)
                }
            }
            
            shouldHighlightRows = true
            tableView.reloadRows(at: reloadPaths, with: .none)
            
        case "Duplicate":
            var indInts = [Int]()
            
            for intArray in stringToIndexesError.values {
                for intError in intArray {
                    if !indInts.contains(intError) {
                        indInts.append(intError)
                    }
                }
            }
            var reloadPaths = [IndexPath]()
            for ind in indInts {
                let indPath = IndexPath(row: ind, section: 0)
                
                if let cell = tableView.cellForRow(at: indPath) as? GeneralTableCell {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.overlayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                        cell.animateDupSlide()
                    })
                } else {
                    reloadPaths.append(indPath)
                }
            }
            
            shouldHighlightRows = true
            tableView.reloadRows(at: reloadPaths, with: .none)
        default:
            print("ERROR!!>>")
        }
    }
    func showWarningIcon() {
        checkForErrors(contentsArray: contents)
        generalSpaces.removeAll()
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
        
    }
    
    @IBOutlet weak var descDoneButton: UIButton!
    @IBAction func descButtonDonePressed(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBOutlet weak var titlesDoneButton: UIButton!
    @IBAction func titlesButtonDonePressed(_ sender: Any) {
        view.endEditing(true)
    }
    @IBOutlet weak var contentsDoneButton: UIButton!
    @IBAction func contentsDonePressed(_ sender: Any) {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomDeleteButton.layer.cornerRadius = 6
        bottomHelpButton.layer.cornerRadius = 6
        
        setUpViews()
        let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
        
        if tableViewHeightAfterAddRow >= 300 {
            tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
            UIView.animate(withDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBOutlet weak var bottomDeleteButton: UIButton!
    @IBOutlet weak var bottomHelpButton: UIButton!
    
    @IBAction func bottomDeletePressed(_ sender: Any) {
        
        let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
        let delete = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
        let confirmDeleteList = NSLocalizedString("confirmDeleteList", comment: "Are you sure you want to delete this list?")
        let cantUndoDeleteList = NSLocalizedString("cantUndoDeleteList", comment: "You can't undo this action.")
        
        
        let alert = UIAlertController(title: confirmDeleteList, message: cantUndoDeleteList, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: delete, style: UIAlertAction.Style.destructive, handler: { _ in
            
            self.deleteTheList?.deleteList()
            SwiftEntryKit.dismiss()
          
        }))
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = bottomDeleteButton
            popoverController.sourceRect = bottomDeleteButton.bounds
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    /// stopper **HERE**
    @IBAction func bottomHelpPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        
        let help = NSLocalizedString("help", comment: "Multipurpose def=Help")
        
        helpViewController.title = help
        
        let navigationController = UINavigationController(rootViewController: helpViewController)
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        
        navigationController.view.layer.cornerRadius = 10
        UINavigationBar.appearance().barTintColor = .black
        helpViewController.edgesForExtendedLayout = []
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
        
        
        attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
        
        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
    
    
    func addNewRow(end: Bool = false) {
        addingNewMatch = true
        
        if end == false { ///User pressed return to insert
          //  print("Return INSERT")
            contents.insert("", at: currentIndexPath + 1)
            
            let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
            
            if tableViewHeightAfterAddRow >= 300 {
                tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
                UIView.animate(withDuration: 0.75, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
            
            checkForErrors(contentsArray: contents)
            currentIndexPath = currentIndexPath + 1
            tableView.insertRows(at: [IndexPath(row: currentIndexPath, section: 0)], with: .automatic)
            
            if currentIndexPath < contents.count - 1 {
                let endRange = currentIndexPath + 1...contents.count - 1
                
                var reloadPaths = [IndexPath]()
                for singleRow in endRange {
                    let deleteIndP = IndexPath(row: singleRow, section: 0)
                    
                    if let cell = tableView.cellForRow(at: deleteIndP) as? GeneralTableCell {
                        cell.indexPath += 1
                    } else {
                        reloadPaths.append(deleteIndP)
                    }
                }
                
                tableView.reloadRows(at: reloadPaths, with: .automatic)
            }
            
            
        } else {
            contents.append("")
            let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
            
            print("HEIGHT CONT: \(tableViewHeightAfterAddRow)")
            if tableViewHeightAfterAddRow >= 300 {
                tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
                UIView.animate(withDuration: 0.75, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            currentIndexPath = contents.count - 1
            tableView.insertRows(at: [IndexPath(row: currentIndexPath, section: 0)], with: .automatic)
        }
        
    }
    func deleteRow(row: Int) {
        contents.remove(at: row)
        let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
        
        print("HEIGHT CONT: \(tableViewHeightAfterAddRow)")
        if tableViewHeightAfterAddRow >= 300 {
            tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
            UIView.animate(withDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        checkForErrors(contentsArray: contents)
        let indP = IndexPath(row: row, section: 0)
        tableView.deleteRows(at: [indP], with: .automatic)
        
        print("del CURR IND: \(row)....count: \(contents.count)")
        if row == contents.count { ///Cont count is now 1 less because remove
            print("last row")
        } else {
            print("Not last row")
            let endRange = row...contents.count - 1
            
            var reloadPaths = [IndexPath]()
            for singleRow in endRange {
                let deleteIndP = IndexPath(row: singleRow, section: 0)
                
                if let cell = tableView.cellForRow(at: deleteIndP) as? GeneralTableCell {
                    cell.indexPath -= 1
                } else {
                    reloadPaths.append(deleteIndP)
                }
            }
            
            tableView.reloadRows(at: reloadPaths, with: .automatic)
            
        }
        
        
        if contents.count == 0 {
            addingNewMatch = true
            contents = [""]
            currentIndexPath = 0
            tableView.insertRows(at: [IndexPath(row: currentIndexPath, section: 0)], with: .automatic)
        }
    }
    func setUpViews() {
        if contents.count == 0 {
            contents.append("")
        }
        
        ///Receive info
        
        titleField.text = name
        descriptionView.text = descriptionOfList
        
        
        topView.layer.cornerRadius = 8
        
        titleField.autocapitalizationType = .words
        titleField.inputAccessoryView = titlesInputView
        
        descriptionView.inputAccessoryView = descInputView
        descriptionView.layer.cornerRadius = 5.25
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = UIColor(named: "TextRim")?.resolvedColor(with: self.traitCollection).cgColor
            
        titleField.layer.cornerRadius = 5.25
        titleField.layer.borderColor = UIColor(named: "TextRim")?.resolvedColor(with: self.traitCollection).cgColor
       
        titleField.layer.borderWidth = 1
        
        titleField.attributedPlaceholder = NSAttributedString(string: "Name",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Gray5")])
        
        titleField.backgroundColor = UIColor(named: "PureBlank")
        descriptionView.backgroundColor = UIColor(named: "PureBlank")
        
        descriptionView.textColor = UIColor(named: "PureBlack")
        matchesHeader.clipsToBounds = true
        matchesHeader.layer.cornerRadius = 8
        matchesHeader.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        tableBottomView.layer.cornerRadius = 8
        tableBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bottomActionView.layer.cornerRadius = 8
        
        descDoneButton.layer.cornerRadius = 6
        titlesDoneButton.layer.cornerRadius = 6
        
        contentsDoneButton.layer.cornerRadius = 6
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Short description"
        placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(named: "Gray5")
        placeholderLabel.isHidden = !descriptionView.text.isEmpty
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.isScrollEnabled = false
        registerNotifications()
    }
    
    
    func showWarnings() {
        
    }
}

extension GeneralViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRow(row: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableviewCell") as! GeneralTableCell
        cell.changedTextDelegate = self
        cell.matchTextField.text = contents[indexPath.row]
        cell.indexPath = indexPath.row
        if addingNewMatch == true {
            addingNewMatch = false
            cell.matchTextField.becomeFirstResponder()
            cell.overlayView.snp.remakeConstraints{ (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(0)
            }
        } else {
            if shouldHighlightRows == true {
                if emptyStringErrors.contains(indexPath.row) {
                    cell.overlayView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                } else {
                    var thisRowContains = false
                    for intArray in stringToIndexesError.values {
                        if intArray.contains(indexPath.row) {
                            thisRowContains = true
                            break
                        }
                    }
                    
                    if thisRowContains == true {
                        cell.overlayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                    } else {
                        cell.overlayView.snp.remakeConstraints{ (make) in
                            make.top.equalToSuperview()
                            make.left.equalToSuperview()
                            make.bottom.equalToSuperview()
                            make.width.equalTo(0)
                        }
                        cell.contentView.layoutIfNeeded()
                    }
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension GeneralViewController: ChangedTextCell {
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func cellPressedDoneButton() {
    }
    
    func textFieldStartedEditing(indexPath: Int) {
        currentIndexPath = indexPath
    }
    func textFieldPressedReturn() {
        addNewRow()
        let origPoint = CGPoint(x: 0, y: (currentIndexPath * 50) + 250)
        let rect = CGRect(origin: origPoint, size: CGSize(width: 50, height: 50))
        
        scrollView.setContentOffset(CGPoint(x: 0, y: (currentIndexPath * 50) + 124), animated: true)
    }
    func textFieldChangedText(indexPath: Int, text: String) {
        contents[indexPath] = text
        showWarningIcon()
    }
    func textFieldEndedEditing(indexPath: Int, text: String) {
        contents[indexPath] = text
        checkForErrors(contentsArray: contents)
    }
    
}

extension GeneralViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 10902 {
            placeholderLabel.isHidden = !descriptionView.text.isEmpty
        } else if textView.tag == 10903 {
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10901 {
            let untitledName = NSLocalizedString("untitledName", comment: "GeneralViewController def=Untitled")
            name = titleField.text ?? untitledName
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 10902:
            descriptionOfList = descriptionView.text
        default:
            break
        }
    }
    

    func showButtonBarMessage(attributes: EKAttributes, titleMessage: String, desc: String, leftButton: String, yesButton: String, image: String = "WhiteWarningShield", specialAction: String = "None") {
        let displayMode = EKAttributes.DisplayMode.inferred
        
        let title = EKProperty.LabelContent(text: titleMessage, style: .init(font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white, displayMode: displayMode))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.systemFont(ofSize: 14, weight: .regular), color: .white,displayMode: displayMode)
        )
        let image = EKProperty.ImageContent(  imageName: image,  displayMode: displayMode,  size: CGSize(width: 35, height: 35),  contentMode: .scaleAspectFit
        )
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description
        )
        let buttonFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let okButtonLabelStyle = EKProperty.LabelStyle( font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white,  displayMode: displayMode
        )
        let okButtonLabel = EKProperty.LabelContent( text: yesButton, style: okButtonLabelStyle
        )
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(#colorLiteral(red: 1, green: 0.9675828359, blue: 0.9005832124, alpha: 1)), displayMode: displayMode
        )
        let closeButtonLabel = EKProperty.LabelContent(text: leftButton, style: closeButtonLabelStyle
        )
        
        if specialAction == "None" {
            let okButton = EKProperty.ButtonContent(
                label: okButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05)) {
                    self.highlightRowsOnError(type: "Duplicate")
                    SwiftEntryKit.dismiss()
            }
            let closeButton = EKProperty.ButtonContent(
                label: closeButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05),
                displayMode: displayMode) { [unowned self] in
                self.fixDuplicates()
            }
            let buttonsBarContent = EKProperty.ButtonBarContent(  with: closeButton, okButton,  separatorColor: Color.Gray.light,  buttonHeight: 60,  displayMode: displayMode,  expandAnimatedly: true  )
            let alertMessage = EKAlertMessage(  simpleMessage: simpleMessage,  imagePosition: .left,  buttonBarContent: buttonsBarContent
            )
            let contentView = EKAlertMessageView(with: alertMessage)
            contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            contentView.layer.cornerRadius = 10
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
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
        
        for (index, match) in contentsArray.enumerated() {
            if match == "" {
                emptyStringErrors.append(index)
            }
        }///First, check for empty string.
        
        
       // if hasEmptyMatch == false {
        ///Now, check for duplicates
        stringToIndexesError.removeAll() //
        if contentsArray.count !=  noDuplicateArray.count {
            
            let differentStrings = Array(Set(contentsArray.filter({ (i: String) in contentsArray.filter({ $0 == i }).count > 1}))) ///ContentsArray, but without duplicates
            
            var firstOccuranceArray = [String]()
            for (index, singleContent) in contentsArray.enumerated() { ///Go through every match
                if differentStrings.contains(singleContent) {
                    if !firstOccuranceArray.contains(singleContent) {
                        firstOccuranceArray.append(singleContent)
                    } else { //A occurance has already occured.
                        stringToIndexesError[singleContent, default: [Int]()].append(index)
                    }
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
//        print("Done checking for errors------------------------------------------------------------------")
//        print("Empty: \(emptyStringErrors)")
//        print("Single Space: \(singleSpaceWarning)")
//        print("Start Space: \(startSpaceWarning)")
//        print("End Space: \(endSpaceWarning)")
//        print("Duplicates: \(stringToIndexesError)")
    }
    
    
    func showDoneAlerts() -> Bool { ///For the end, done
        var showAnAlert = false
        
        if emptyStringErrors.count >= 1 {
            let cantHaveEmptyMatch = NSLocalizedString("cantHaveEmptyMatch", comment: "GeneralViewController def=Can't have an empty match!")
            
            let youHaveXEmptyMatches = NSLocalizedString("youHave %d EmptyMatches",
                                                                      comment:"GeneralViewController def=You have x empty matches!")
            
            
            var matchesPlural = String.localizedStringWithFormat(youHaveXEmptyMatches, emptyStringErrors.count)
            
            if emptyStringErrors.count == 1 { matchesPlural = cantHaveEmptyMatch }
            showAnAlert = true
            SwiftEntryKitTemplates().displaySEK(message: matchesPlural, backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top, duration: CGFloat(0.8))
            
            highlightRowsOnError(type: "EmptyMatch")
        } else if stringToIndexesError.count >= 1 { ///No empty errors. Only duplicates.
            var titleMessage = ""
            
            let dupStrings = stringToIndexesError.keys
            var duplicateStringArray = [String]()
            for dup in dupStrings {
                duplicateStringArray.append(dup)
            }
            
            switch dupStrings.count {
            case 0:
                titleMessage = ""
            case 1:
                
                if let differentPaths = stringToIndexesError[duplicateStringArray[0]] {
                    let aDuplicateOriginal = NSLocalizedString("aDuplicateOriginal", comment: "GeneralViewController def=a duplicate.")
                    
                    
                    var aDuplicate = aDuplicateOriginal
//                    if differentPaths.count == 1 {
//                        aDuplicate = "a duplicate."
//                    } else
                    if differentPaths.count == 2 {
                        let twoDuplicates = NSLocalizedString("twoDuplicates", comment: "GeneralViewController def=2 duplicates.")
                        
                        aDuplicate = twoDuplicates
                    } else {
                        let aCoupleDuplicates = NSLocalizedString("aCoupleDuplicates", comment: "GeneralViewController def=a couple duplicates.")
                        aDuplicate = aCoupleDuplicates
                    }
                    
                    let xHasXDuplicates = NSLocalizedString("%@ has %@", comment:"GeneralViewController def=\"\(duplicateStringArray[0])\" has \(aDuplicate)")

//                    titleMessage = "\"\(duplicateStringArray[0])\" has \(aDuplicate)"
                    titleMessage = String.localizedStringWithFormat(xHasXDuplicates, duplicateStringArray[0], aDuplicate)
                }
            case 2:
                let xAndxHaveDuplicates = NSLocalizedString("%@ and %@ have",
                                                            comment:"GeneralViewController def=\"\(duplicateStringArray[0])\" and \"\(duplicateStringArray[1])\" have duplicates.")

                titleMessage = String.localizedStringWithFormat(xAndxHaveDuplicates, duplicateStringArray[0], duplicateStringArray[1])
//                titleMessage = "\"\(duplicateStringArray[0])\" and \"\(duplicateStringArray[1])\" have duplicates."
                
            case 3..<4:
                var newString = ""
                for (index, message) in duplicateStringArray.enumerated() {
                    if index != duplicateStringArray.count - 1 {
                        newString.append("\"\(message)\", ")
                    } else {
                        
                        let and = NSLocalizedString("and", comment: "Multipurpose def=and")
                        newString.append(" \(and) \"\(message)\"")
                    }

             //       print("NEW: \(newString)")
                }
                
                let spaceHaveDuplicates = NSLocalizedString("spaceHaveDuplicates", comment:"GeneralViewController def= have duplicates.")
                    
                titleMessage = newString + spaceHaveDuplicates
            default:
                
                let youHaveLotsDuplicates = NSLocalizedString("youHaveLotsDuplicates",
                                                              comment:"GeneralViewController def=You have a lot of duplicate matches.")
//                titleMessage = "You have a lot of duplicate matches."
                titleMessage = youHaveLotsDuplicates
            }
           // print("title: \(titleMessage)")
            if titleMessage != "" {
                
                
                
                
                
                titleMessage = titleMessage.typographized(language: "en")
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
                
                let wouldYouLikeDeleteDup = NSLocalizedString("wouldYouLikeDeleteDup",
                comment:"GeneralViewController def=Would you like us to delete the duplicates?")
                
                let leftButtonDeleteSave = NSLocalizedString("leftButtonDeleteSave",
                comment:"GeneralViewController def=Yes, Delete and save")
                
                let rightButtonFixItMyself = NSLocalizedString("rightButtonFixItMyself",
                comment:"GeneralViewController def=I'll fix it myself")
                
                
                showButtonBarMessage(attributes: attributes, titleMessage: titleMessage, desc: wouldYouLikeDeleteDup, leftButton: leftButtonDeleteSave, yesButton: rightButtonFixItMyself)
            }
        }
        return showAnAlert
    }

    
    func fixDuplicates() {
        
        print("dup errors: \(stringToIndexesError)")
        var toDeleteArray = [IndexPath]()
        var toDeleteValues = [Int]()
        for singleDup in stringToIndexesError {
            for value in singleDup.value {
                let newInd = IndexPath(row: value, section: 0)
                toDeleteArray.append(newInd)
                toDeleteValues.append(value)
                //contents.remove(at: value)
            }
        }
        //let indexAnimals = [0, 3, 4]
        contents = contents
            .enumerated()
            .filter { !toDeleteValues.contains($0.offset) }
            .map { $0.element }
        
        tableView.performBatchUpdates({
            self.tableView.deleteRows(at: toDeleteArray, with: .automatic)
        }) { _ in
            self.doneWithEditingGeneral(overrideDone: true)
        }
        
        
        
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


//extension String {
//  func removeFirstChars(length: Int) -> String {
//        if length <= 0 {
//            return self
//        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
//            return self.substring(from: to)
//
//        } else {
//            return ""
//        }
//    }
//}
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
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
