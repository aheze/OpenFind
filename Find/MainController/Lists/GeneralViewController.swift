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

protocol GetGeneralInfo: class {
    func returnNewGeneral(nameOfList: String, desc: String, contentsOfList: String, interrupt: Bool)
}

class GeneralViewController: UIViewController, ReturnGeneralNow {
    
    
  
    
    weak var generalDelegate: GetGeneralInfo?

    @IBOutlet var titlesInputView: UIView!
    @IBOutlet var descInputView: UIView!
    @IBOutlet var inputButtonsView: UIView!

    @IBOutlet weak var contentsContainer: UIView!
    @IBOutlet weak var contentsTextView: UITextView!
     
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    //weak var changedGeneralDelegate: GetGeneralInfo?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    var placeholderLabel : UILabel!
    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = ""
    
    func doneWithEditingGeneral(overrideDone: Bool) {
        view.endEditing(true)
        if overrideDone == true {
            print("override!!")
            generalDelegate?.returnNewGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents, interrupt: false)
            SwiftEntryKit.dismiss()
        } else {
            let textString = contentsTextView.text.removeFirstChars(length: 3)
            let splits = textString.components(separatedBy: "\n \u{2022} ")
            print(splits)
            
            let noDuplicateArray = splits.uniques
            print("NO DUP: \(noDuplicateArray)")
            
            var hasEmptyMatch = 0
            var hasSingleSpaceMatch = 0
            var hasSpaceInMatch = 0
            for match in splits {
                if match == "" { hasEmptyMatch += 1 }
                if match == " " { hasSingleSpaceMatch += 1 }
                if match.contains(" ") { hasSpaceInMatch += 1 }
            }
            
            if (hasEmptyMatch >= 1) {
                print("asd")
                var matchesPlural = "You have \(hasEmptyMatch) empty matches."
                if hasEmptyMatch == 1 { matchesPlural = "You have a match that is empty." }
                SwiftEntryKitTemplates().displaySEK(message: matchesPlural, backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top, duration: CGFloat(0.68))
            } else if (hasSingleSpaceMatch >= 1) {
                print("asdasd")
                var attributes = EKAttributes.topFloat
                attributes.displayDuration = .infinity
                attributes.entryInteraction = .absorbTouches
                attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
                attributes.screenInteraction = .absorbTouches
                showButtonBarMessage(attributes: attributes)
            } else {
                print("NOTHING WRONG!")
                generalDelegate?.returnNewGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contents, interrupt: false)
            }
            
        }
    }
    func updateInfo() {
        print("update")
        doneWithEditingGeneral(overrideDone: false)
    }
        @IBOutlet weak var descDoneButton: UIButton!
        @IBAction func descButtonDonePressed(_ sender: Any) {
            view.endEditing(true)
            //print("asd")
            //name = titleField.text ?? "Untitled"
        }
        
        @IBOutlet weak var titlesDoneButton: UIButton!
        @IBAction func titlesButtonDonePressed(_ sender: Any) {
            view.endEditing(true)
            //descriptionOfList = descriptionField.text
        }
        
        @IBOutlet weak var contentsDoneButton: UIButton!
        @IBAction func contentsDonePressed(_ sender: Any) {
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
        func setUpViews() {
            
            
            titleField.autocapitalizationType = .words
            contentsContainer.layer.cornerRadius = 12
           // imageContainer.clipsToBounds = true
            //imageContainer.layer.cornerRadius = 12
            contentsTextView.layer.cornerRadius = 6
            
            contentsTextView.inputAccessoryView = inputButtonsView
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
            
            //doneWithListButton.layer.cornerRadius = 4
            descDoneButton.layer.cornerRadius = 4
            titlesDoneButton.layer.cornerRadius = 4
            
            contentsDoneButton.layer.cornerRadius = 4
            
            placeholderLabel = UILabel()
            placeholderLabel.text = "Enter some text..."
            placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            descriptionView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionView.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.isHidden = !descriptionView.text.isEmpty
            
        }
}

//protocol NewListMade: class {
//    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String)
//}


extension GeneralViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        print("CHANGE")
        if textView.tag == 10902 {
            //print("shkdhkusdf")
            placeholderLabel.isHidden = !descriptionView.text.isEmpty
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
            contents = contentsTextView.text
        default:
            break
        }
        print("END")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // If the replacement text is "\n" and the
        // text view is the one you want bullet points
        // for
        switch textView.tag {
            
        case 10903:
        if (text == "\n") {
            print("newline")
            // If the replacement text is being added to the end of the
            // text view, i.e. the new index is the length of the old
            // text view's text...


            if range.location == textView.text.count {
                print("KJAHSDFJJSKDF")
                // Simply add the newline and bullet point to the end
                if let textOfView = textView.text {
                    let updatedText: String = "\(textOfView)\n \u{2022} "
                    textView.text = updatedText
                }
                
            } else {
                print("ADJKGF")
                // Get the replacement range of the UITextView
                let beginning: UITextPosition = textView.beginningOfDocument
                let start: UITextPosition = textView.position(from: beginning, offset: range.location)!
                let end: UITextPosition = textView.position(from: start, offset: range.length)!
                //var end: UITextPosition = textView.positionFromPosition(start, offset: range.length)!
                let textRange: UITextRange = textView.textRange(from: start, to: end)!
                // Insert that newline character *and* a bullet point
                // at the point at which the user inputted just the
                // newline character
                textView.replace(textRange, withText: "\n \u{2022} ")
                // Update the cursor position accordingly
                //var cursor: Range = NSRange(range.location + "\n \u{2022} ".count, 0)
//                let newPosition = textView.endOfDocument
//                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                
                var arbitraryValue: Int = 0
                arbitraryValue += range.location
                arbitraryValue += 3
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: arbitraryValue) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                //textView.selectedRange = newPosition
            }
            let newHeightT = contentsTextView.sizeThatFits(CGSize(width: contentsTextView.frame.size.width, height: CGFloat(MAXFLOAT))).height
            print("newh: \(newHeightT)")
            if newHeightT >= 300 {
                textViewHeightConstraint.constant = newHeightT
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
            return false


        } else if text == "" && range.length > 0 { //Backspace
            print(range.length)
            if range.location == 2 {
                return false ///don't delete first bullet point
            }
            let beginning: UITextPosition = textView.beginningOfDocument
            if let cursorRange = textView.selectedTextRange {
                print("position1: \(textView.selectedTextRange)")
                // get the position one character before the cursor start position
                if let newPosition = textView.position(from: cursorRange.start, offset: -2) {
                    print("position: \(newPosition)")
                    if let checkTextRange = textView.textRange(from: newPosition, to: cursorRange.start) {
                        if let checkText = textView.text(in: checkTextRange) {
                            if textView.text.count >= 3 {
                                switch checkText {
                                case " \u{2022}":
                                        print("back")
                                    let rangLoc = 1
                                    let start: UITextPosition = textView.position(from: beginning, offset: range.location - rangLoc)!
                                    let end: UITextPosition = textView.position(from: start, offset: range.length + rangLoc)!
                                    let textRange: UITextRange = textView.textRange(from: start, to: end)!
                                    textView.replace(textRange, withText: "")
                                    print(range.location)
                                case "\u{2022} ":
                                    let rangLoc = 2
                                    let start: UITextPosition = textView.position(from: beginning, offset: range.location - rangLoc)!
                                    let end: UITextPosition = textView.position(from: start, offset: range.length + rangLoc)!
                                    let textRange: UITextRange = textView.textRange(from: start, to: end)!
                                    textView.replace(textRange, withText: "")
                                    print(range.location)
                                default:
                                    print("normal backspace, don't delete bullet point")
                                }
                                let newHeightT = contentsTextView.sizeThatFits(CGSize(width: contentsTextView.frame.size.width, height: CGFloat(MAXFLOAT))).height
                                print("newh: \(newHeightT)")
                                if newHeightT >= 300 {
                                    textViewHeightConstraint.constant = newHeightT
                                    UIView.animate(withDuration: 0.2) {
                                        self.view.layoutIfNeeded()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        default:
            print("wrong text VIEW")
    }
        
        // Else return yes
        return true
    
    }

    func showButtonBarMessage(attributes: EKAttributes) {
        let displayMode = EKAttributes.DisplayMode.inferred
        
        let title = EKProperty.LabelContent(
            text: "Are you sure you want to have a match that is a space?",
            style: .init(
                font: UIFont.systemFont(ofSize: 20, weight: .bold),
                color: .white,
                displayMode: displayMode
            )
        )
        let description = EKProperty.LabelContent(
            text: "Probably not a good idea. Maybe check your matches?",
            style: .init(
                font: UIFont.systemFont(ofSize: 14, weight: .regular),
                color: .white,
                displayMode: displayMode
            )
        )
        let image = EKProperty.ImageContent(
            imageName: "WhiteWarningShield",
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
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: UIFont.systemFont(ofSize: 20, weight: .bold),
            color: .white,
            displayMode: displayMode
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "I'll go check",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05)) {
                SwiftEntryKit.dismiss()
        }
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: EKColor(#colorLiteral(red: 1, green: 0.9675828359, blue: 0.9005832124, alpha: 1)),
            displayMode: displayMode
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "Ignore and save",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05),
            displayMode: displayMode) { [unowned self] in
             print("cool")
                self.doneWithEditingGeneral(overrideDone: true)
                
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton, closeButton,
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
