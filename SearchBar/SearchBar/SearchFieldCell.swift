//
//  SearchFieldCell.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

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

        if let attributes = layoutAttributes as? FieldLayoutAttributes {
            
            let percentageVisible = 1 - attributes.percentage
            
            leftView.alpha = percentageVisible
            rightView.alpha = percentageVisible
            
            leftViewWidthC.constant = percentageVisible * Constants.fieldLeftViewWidth
            rightViewWidthC.constant = percentageVisible * Constants.fieldRightViewWidth
            
        }
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
