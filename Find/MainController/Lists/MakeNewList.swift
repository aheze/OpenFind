//
//  MakeNewList.swift
//  Find
//
//  Created by Andrew on 1/26/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class MakeNewList: UIViewController {
    
    @IBOutlet weak var contentsContainer: UIView!
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBAction func changeImagePressed(_ sender: UIButton) {
        print("change image")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentsContainer.layer.cornerRadius = 12
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 12
        contentsTextView.layer.cornerRadius = 6
        
        
    }
    
}

extension MakeNewList: UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // If the replacement text is "\n" and the
        // text view is the one you want bullet points
        // for
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
            
            let beginning: UITextPosition = textView.beginningOfDocument
            if let cursorRange = textView.selectedTextRange {
                // get the position one character before the cursor start position
                if let newPosition = textView.position(from: cursorRange.start, offset: -2) {
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
