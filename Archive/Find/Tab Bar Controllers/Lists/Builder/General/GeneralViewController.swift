//
//  GeneralViewController.swift
//  Find
//
//  Created by Andrew on 2/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import RealmSwift
import SwiftEntryKit
import UIKit

protocol DeleteList: class {
    func deleteList()
}

class GeneralViewController: UIViewController {
    func receiveGeneral(nameOfList: String, desc: String, contentsOfList: [String]) {
        name = nameOfList
        descriptionOfList = desc
        contents = contentsOfList
    }

    @IBOutlet var titlesInputView: UIView!
    @IBOutlet var descInputView: UIView!
    @IBOutlet var inputButtonsView: UIView!

    @IBOutlet var wordsHeaderLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomActionView: UIView!
    @IBOutlet var matchesHeader: UIView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var tableBottomView: UIView!
    
    @IBOutlet var newMatchButton: UIButton!
    @IBAction func newMatchPressed(_ sender: Any) {
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
    var stringToIndexesError = [String: [Int]]() /// A dictionary of the DUPLICATE rows- not the first occurrence. These rows should be deleted.
    
    var deleteThisList: (() -> Void)?
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionView: UITextView!
    var placeholderLabel: UILabel!
    
    // MARK: Editing properties

    var name = ""
    var descriptionOfList = ""
    var contents = [String]()
    
    func highlightRowsOnError(type: String) { /// Highlight the rows when done is pressed and there is an error
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
                    
                    let errorTitle = AccessibilityText(text: "Has error: this is a duplicate", isRaised: true)
                    let summaryTitle = AccessibilityText(text: "Word to Find", isRaised: false)
                    let accessibilityLabel = UIAccessibility.makeAttributedText([errorTitle, summaryTitle])
                    
                    cell.matchTextField.accessibilityAttributedLabel = accessibilityLabel
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
                    
                    let errorTitle = AccessibilityText(text: "Has error: this is a duplicate", isRaised: true)
                    let summaryTitle = AccessibilityText(text: "Word to Find", isRaised: false)
                    let accessibilityLabel = UIAccessibility.makeAttributedText([errorTitle, summaryTitle])
                    
                    cell.matchTextField.accessibilityAttributedLabel = accessibilityLabel
                } else {
                    reloadPaths.append(indPath)
                }
            }
            
            shouldHighlightRows = true
            tableView.reloadRows(at: reloadPaths, with: .none)
        default:
            break
        }
    }
    
    @IBOutlet var descDoneButton: UIButton!
    @IBAction func descButtonDonePressed(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBOutlet var titlesDoneButton: UIButton!
    @IBAction func titlesButtonDonePressed(_ sender: Any) {
        view.endEditing(true)
    }

    @IBOutlet var contentsDoneButton: UIButton!
    @IBAction func contentsDonePressed(_ sender: Any) {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomDeleteButton.layer.cornerRadius = 6
        bottomHelpButton.layer.cornerRadius = 6
        
        setupViews()
        let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
        
        if tableViewHeightAfterAddRow >= 300 {
            tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
            UIView.animate(withDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        titleField.accessibilityLabel = "Name"
        descriptionView.accessibilityLabel = "Description"
        wordsHeaderLabel.accessibilityTraits = .header
        wordsHeaderLabel.accessibilityHint = "The words that the list contains"
    }
    
    @IBOutlet var bottomDeleteButton: UIButton!
    @IBOutlet var bottomHelpButton: UIButton!
    
    @IBAction func bottomDeletePressed(_ sender: Any) {
        let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
        let delete = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
        let confirmDeleteList = NSLocalizedString("confirmDeleteList", comment: "Are you sure you want to delete this list?")
        let cantUndoDeleteList = NSLocalizedString("cantUndoDeleteList", comment: "You can't undo this action.")
        
        let alert = UIAlertController(title: confirmDeleteList, message: cantUndoDeleteList, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: delete, style: UIAlertAction.Style.destructive, handler: { _ in
            
            self.deleteThisList?()
            
            SwiftEntryKit.dismiss()
          
        }))
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = bottomDeleteButton
            popoverController.sourceRect = bottomDeleteButton.bounds
        }
        present(alert, animated: true, completion: nil)
    }

    /// stopper **HERE**
    @IBAction func bottomHelpPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        
        let help = NSLocalizedString("help", comment: "Multipurpose def=Help")
        helpViewController.title = help
   
        let navigationController = UINavigationController(rootViewController: helpViewController)
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func addNewRow(end: Bool = false) {
        addingNewMatch = true
        
        if end == false { /// User pressed return to insert
            contents.insert("", at: currentIndexPath + 1)
            
            let tableViewHeightAfterAddRow = CGFloat(50 * contents.count)
            
            if tableViewHeightAfterAddRow >= 300 {
                tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
                UIView.animate(withDuration: 0.75, animations: {
                    self.view.layoutIfNeeded()
                })
            }

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
        
        if tableViewHeightAfterAddRow >= 300 {
            tableViewHeightConstraint.constant = tableViewHeightAfterAddRow
            UIView.animate(withDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        let indP = IndexPath(row: row, section: 0)
        tableView.deleteRows(at: [indP], with: .automatic)
        
        if row == contents.count { /// Cont count is now 1 less because remove
        } else {
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

    func setupViews() {
        if contents.count == 0 {
            contents.append("")
        }
        
        /// Receive info
        
        titleField.text = name
        descriptionView.text = descriptionOfList
        
        topView.layer.cornerRadius = 8
        
        titleField.autocapitalizationType = .words
        titleField.inputAccessoryView = titlesInputView
        
        descriptionView.inputAccessoryView = descInputView
        descriptionView.layer.cornerRadius = 5.25
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = UIColor(named: "TextRim")?.resolvedColor(with: traitCollection).cgColor
            
        titleField.layer.cornerRadius = 5.25
        titleField.layer.borderColor = UIColor(named: "TextRim")?.resolvedColor(with: traitCollection).cgColor
       
        titleField.layer.borderWidth = 1
        
        let name = NSLocalizedString("nameGeneral", comment: "GeneralViewController")
        titleField.attributedPlaceholder = NSAttributedString(string: name,
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
        
        let shortDescription = NSLocalizedString("shortDescriptionPlaceholder", comment: "GeneralViewController")
        
        placeholderLabel.text = shortDescription
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
    
    func showWarnings() {}
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
        
        cell.deleteButton.accessibilityLabel = "Delete"
        cell.deleteButton.accessibilityHint = "Delete this word"
        if !UIAccessibility.isVoiceOverRunning {
            cell.deleteButton.isHidden = true
        }
        
        cell.deletePressed = { [weak self] in
            guard let self = self else { return }
            self.deleteRow(row: indexPath.row)
        }
        
        let summaryTitle = AccessibilityText(text: "Word", isRaised: false)
        cell.matchTextField.accessibilityHint = "A word that this list will contain"
        
        var details: AccessibilityText?
        
        if addingNewMatch == true {
            addingNewMatch = false
            cell.matchTextField.becomeFirstResponder()
            cell.overlayView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(0)
            }
        } else {
            if shouldHighlightRows == true {
                if emptyStringErrors.contains(indexPath.row) {
                    cell.overlayView.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                    details = AccessibilityText(text: "Has error: must not be empty", isRaised: true)
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
                        details = AccessibilityText(text: "Has error: this is a duplicate", isRaised: true)
                    } else {
                        cell.overlayView.snp.remakeConstraints { make in
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
        
        let accessibilityLabel: NSMutableAttributedString
        
        if let details = details {
            accessibilityLabel = UIAccessibility.makeAttributedText([summaryTitle, details])
        } else {
            accessibilityLabel = UIAccessibility.makeAttributedText([summaryTitle])
        }
        cell.matchTextField.accessibilityAttributedLabel = accessibilityLabel
        
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

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    func cellPressedDoneButton() {}
    
    func textFieldStartedEditing(indexPath: Int) {
        currentIndexPath = indexPath
    }

    func textFieldPressedReturn() {
        addNewRow()
        scrollView.setContentOffset(CGPoint(x: 0, y: (currentIndexPath * 50) + 124), animated: true)
    }

    func textFieldChangedText(indexPath: Int, text: String) {
        contents[indexPath] = text
    }

    func textFieldEndedEditing(indexPath: Int, text: String) {
        contents[indexPath] = text
    }
}

extension GeneralViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 10902 {
            placeholderLabel.isHidden = !descriptionView.text.isEmpty
        } else if textView.tag == 10903 {}
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
}

extension GeneralViewController {
    func fixDuplicates(completion: @escaping () -> Void) {
        var toDeleteArray = [IndexPath]()
        var toDeleteValues = [Int]()
        for singleDup in stringToIndexesError {
            for value in singleDup.value {
                let newInd = IndexPath(row: value, section: 0)
                toDeleteArray.append(newInd)
                toDeleteValues.append(value)
            }
        }
        
        contents = contents
            .enumerated()
            .filter { !toDeleteValues.contains($0.offset) }
            .map { $0.element }
        
        tableView.performBatchUpdates({
            self.tableView.deleteRows(at: toDeleteArray, with: .automatic)
        }) { _ in
            completion()
        }
    }
}

extension StringProtocol {
    subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count - range.lowerBound)) }
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
