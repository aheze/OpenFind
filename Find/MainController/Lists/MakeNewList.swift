//
//  MakeNewList.swift
//  Find
//
//  Created by Andrew on 1/26/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol NewListMade: class {
    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String)
}
class MakeNewList: UIViewController  {
    
    @IBOutlet weak var doneWithListButton: UIButton!
    
    @IBAction func doneWithListPressed(_ sender: Any) {
        if contentsTextView.text.isEmpty {
            SwiftEntryKitTemplates().displaySEK(message: "Can't create a list with no contents!", backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top)
        } else {
            view.endEditing(true)
            print("name: \(name), description: \(descriptionOfList), contents: \(contents), imageName: \(iconImageName), imageColor: \(iconColorName)")
            newListDelegate?.madeNewList(name: name, description: descriptionOfList, contents: contents, imageName: iconImageName, imageColor: iconColorName)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBOutlet var titlesInputView: UIView!
    @IBOutlet var descInputView: UIView!
    @IBOutlet var inputButtonsView: UIView!
    
    @IBOutlet weak var contentsContainer: UIView!
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    weak var newListDelegate: NewListMade?
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    var placeholderLabel : UILabel!
    
    var name = "Untitled"
    var descriptionOfList = "No description..."
    var contents = ""
    var iconImageName = "square.grid.2x2"
    var iconColorName = "00AEEF"
    
    @IBAction func changeImagePressed(_ sender: UIButton) {
        print("change image")
        var attributes = EKAttributes.centerFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - 120)
        attributes.positionConstraints.size.width = .constant(value: UIScreen.main.bounds.size.width - 60)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .zero))
        attributes.roundCorners = .all(radius: 10)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.lifecycleEvents.willDisappear = {
            
//            self.fadeSelectOptions(fadeOut: "fade out")
//            self.selectButtonSelected = false
//            self.enterSelectMode(entering: false)
            if let overlay = self.view.viewWithTag(0010) {
                UIView.animate(withDuration: 0.3, animations: {
                    overlay.alpha = 0
                }) { _ in
                    overlay.removeFromSuperview()
                }
            }
        }
        let changeImageView = ImagePickerList()
        SwiftEntryKit.display(entry: changeImageView, using: attributes)
        let newOverlayView = UIView()
        newOverlayView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.42578125)
        newOverlayView.alpha = 0
        view.addSubview(newOverlayView)
        newOverlayView.tag = 0010
        newOverlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.5, animations: {
            newOverlayView.alpha = 1
        })
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
    
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func donePressed(_ sender: Any) {
        view.endEditing(true)
        //contents = contentsTextView.text
    }
    
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControl(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            print("First Segment Selected")
        case 1:
            print("Second Segment Selected")
        default:
            break
        }
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
        contentsContainer.layer.cornerRadius = 12
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 12
        contentsTextView.layer.cornerRadius = 6
        
        contentsTextView.inputAccessoryView = inputButtonsView
        titleField.inputAccessoryView = titlesInputView
        descriptionField.inputAccessoryView = descInputView
        
        //titleField.tag = 10901
        //descriptionField.tag = 10902
        //contentsTextView.tag = 10903
        
        descriptionField.layer.cornerRadius = 5.25
        descriptionField.layer.borderWidth = 1
        descriptionField.layer.borderColor = #colorLiteral(red: 0.9136029482, green: 0.9136029482, blue: 0.9136029482, alpha: 1)
        
        titleField.layer.cornerRadius = 5.25
        titleField.layer.borderColor = #colorLiteral(red: 0.9136029482, green: 0.9136029482, blue: 0.9136029482, alpha: 1)
        titleField.layer.borderWidth = 1
        //titleField.layer.borderWidth = 1
        
        helpButton.layer.cornerRadius = 4
        
        doneWithListButton.layer.cornerRadius = 4
        descDoneButton.layer.cornerRadius = 4
        titlesDoneButton.layer.cornerRadius = 4
        
        doneButton.layer.cornerRadius = 4
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionField.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionField.text.isEmpty
        
    }
    
}

extension MakeNewList: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 10902 {
            //print("shkdhkusdf")
            placeholderLabel.isHidden = !descriptionField.text.isEmpty
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
            print(descriptionField.text)
            descriptionOfList = descriptionField.text
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
                // Simply add the newline and bullet point to the end
                if let textOfView = textView.text {
                    let updatedText: String = "\(textOfView)\n \u{2022} "
                    textView.text = updatedText
                }
                
            }
            else {

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
