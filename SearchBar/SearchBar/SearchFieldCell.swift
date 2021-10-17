//
//  SearchFieldCell.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    
    open var transitionProgress: CGFloat = 0.0
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.transitionProgress = transitionProgress
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.transitionProgress == transitionProgress
        else { return false }
    
        return super.isEqual(object)
    }
    
}

class SearchFieldCell: UICollectionViewCell {
    
    var textChanged: ((String) -> Void)?
    
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var leftView: LeftView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightView: RightView!
    
    
    @IBOutlet weak var baseViewTopC: NSLayoutConstraint!
    @IBOutlet weak var baseViewRightC: NSLayoutConstraint!
    @IBOutlet weak var baseViewBottomC: NSLayoutConstraint!
    @IBOutlet weak var baseViewLeftC: NSLayoutConstraint!
    
    @IBOutlet weak var leftViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var rightViewWidthC: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        textField.delegate = self
        textField.font = Constants.fieldFont
        textField.isEnabled = false
        
        baseViewTopC.constant = Constants.fieldBaseViewTopPadding
        baseViewRightC.constant = Constants.fieldBaseViewRightPadding
        baseViewBottomC.constant = Constants.fieldBaseViewBottomPadding
        baseViewLeftC.constant = Constants.fieldBaseViewLeftPadding
        
        leftViewWidthC.constant = Constants.fieldLeftViewWidth
        rightViewWidthC.constant = Constants.fieldRightViewWidth
        
        leftView.tapped = { [weak self] in
            print("Tap!")
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
//        print("Applying attributes")
//        if let attributes = layoutAttributes as? FieldLayoutAttributes {
//
//            print("caster attributes")
//            print(frame.width)
//        }
    }
}

extension SearchFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            textChanged?(updatedText)
        }
        
        return true
    }
}
