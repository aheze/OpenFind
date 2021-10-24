//
//  SearchFieldCell.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchFieldCell: UICollectionViewCell {
    
    /// main content, constraints applied
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
    
    var fieldChanged: ((Field) -> Void)?
    
    /// set field from datasource
    func setField(_ field: Field) {
        self.field = field
        self.textField.text = field.value.getText()
    }
    
    private var field = Field(value: .string("")) {
        didSet {
            switch field.value {
            case .string(_):
                break
            case .list(_):
                break
            case .addNew(let addNewState):
                switch addNewState {
                case .hugging:
                    showAddNew(true, changeColorOnly: false)
                    return
                case .animatingToFull:
                    return
                }
            }
            showAddNew(false, changeColorOnly: false)
        }
    }
    
    
    @IBOutlet weak var addNewView: UIView!
    @IBOutlet weak var addNewImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = Constants.fieldBackgroundColor
        contentView.layer.cornerRadius = Constants.fieldCornerRadius
        
        textField.delegate = self
        textField.font = Constants.fieldFont
        textField.textColor = .white
        
        textField.attributedPlaceholder = NSAttributedString(
            string: Constants.addTextPlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        
        baseViewTopC.constant = Constants.fieldBaseViewTopPadding
        baseViewRightC.constant = Constants.fieldBaseViewRightPadding
        baseViewBottomC.constant = Constants.fieldBaseViewBottomPadding
        baseViewLeftC.constant = Constants.fieldBaseViewLeftPadding
        
        leftViewWidthC.constant = 0
        rightViewWidthC.constant = 0
        
//        leftView.tapped = { [weak self] in
//            print("Tap!")
//        }
        
        
        let configuration = UIImage.SymbolConfiguration(font: Constants.fieldFont)
        addNewImageView.preferredSymbolConfiguration = configuration
        
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? FieldLayoutAttributes {
            let percentageVisible = 1 - attributes.percentage
            
            if case Field.Value.addNew(.hugging) = field.value {
                leftView.alpha = 0
                rightView.alpha = 0
            } else if case Field.Value.addNew(.animatingToFull) = field.value {
                
            } else {
                leftView.alpha = percentageVisible
                rightView.alpha = percentageVisible
            }
            
            leftViewWidthC.constant = percentageVisible * Constants.fieldLeftViewWidth
            rightViewWidthC.constant = percentageVisible * Constants.fieldRightViewWidth
        }
    }
    
    func showAddNew(_ show: Bool, changeColorOnly: Bool) {
        
        contentView.backgroundColor = show ? .blue : Constants.fieldBackgroundColor
        
        if changeColorOnly { return }
        
        if show {
            textField.alpha = 0
            leftView.alpha = 0
            rightView.alpha = 0
            addNewView.alpha = 1
            addNewView.transform = .identity
        } else {
            textField.alpha = 1
            leftView.alpha = 1
            rightView.alpha = 1
            addNewView.alpha = 0
            addNewView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
    }
}

extension SearchFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            field.value = .string(updatedText)
            fieldChanged?(field)
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


