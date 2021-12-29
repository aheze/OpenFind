//
//  SearchFieldCell.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchFieldCell: UICollectionViewCell {
    /// main content, constraints applied
    @IBOutlet var baseView: UIView!
    
    @IBOutlet var leftView: LeftView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var rightView: RightView!
    
    /// full-width button
    @IBOutlet var triggerButton: UIButton!
    @IBAction func triggerButtonPressed(_ sender: Any) {
        entireViewTapped?()
    }
    
    @IBOutlet var baseViewTopC: NSLayoutConstraint!
    @IBOutlet var baseViewRightC: NSLayoutConstraint!
    @IBOutlet var baseViewBottomC: NSLayoutConstraint!
    @IBOutlet var baseViewLeftC: NSLayoutConstraint!
    
    @IBOutlet var leftViewWidthC: NSLayoutConstraint!
    @IBOutlet var rightViewWidthC: NSLayoutConstraint!
    
    @IBOutlet var addNewView: UIView!
    @IBOutlet var addNewViewCenterHorizontallyWithSuperview: NSLayoutConstraint!
    @IBOutlet var addNewViewCenterHorizontallyWithRightC: NSLayoutConstraint!
    @IBOutlet var addNewViewWidthC: NSLayoutConstraint!
    @IBOutlet var addNewViewHeightC: NSLayoutConstraint!
    @IBOutlet var addNewIconView: ClearIconView!
    
    var leftViewTapped: (() -> Void)?
    var rightViewTapped: (() -> Void)?
    var entireViewTapped: (() -> Void)?
    
    var fieldChanged: ((Field) -> Void)?
    
    /// set field from datasource
    /// ONLY cellForRowAt
    func setField(_ field: Field) {
        self.field = field
        textField.text = field.text.value.getText()
        
        switch field.text.value {
        case .string:
            break
        case .list:
            break
        case .addNew:
            let (_, animations, completion) = showAddNew(true, changeColorOnly: false)
            animations()
            completion()
            contentView.backgroundColor = SearchConstants.fieldBackgroundColor
            return
        }
        let (_, animations, completion) = showAddNew(false, changeColorOnly: false)
        animations()
        completion()
    }
    
    func updateField(_ makeChangesTo: (inout Field) -> Void) {
        makeChangesTo(&field)
        fieldChanged?(field)
    }
    
    var field = Field(text: .init(value: .string(""), colorIndex: 0)) {
        /// perform instant updates, no animation
        didSet {
            textField.isEnabled = field.focused
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = SearchConstants.fieldBackgroundColor
        contentView.layer.cornerRadius = SearchConstants.fieldCornerRadius
        
        textField.delegate = self
        textField.font = SearchConstants.fieldFont
        textField.textColor = .white
        
        textField.attributedPlaceholder = NSAttributedString(
            string: SearchConstants.addTextPlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        
        baseViewTopC.constant = SearchConstants.fieldBaseViewTopPadding
        baseViewRightC.constant = SearchConstants.fieldBaseViewRightPadding
        baseViewBottomC.constant = SearchConstants.fieldBaseViewBottomPadding
        baseViewLeftC.constant = SearchConstants.fieldBaseViewLeftPadding
        
        addNewViewWidthC.constant = SearchConstants.clearIconLength
        addNewViewHeightC.constant = SearchConstants.clearIconLength
        
        leftViewWidthC.constant = 0
        rightViewWidthC.constant = 0
        
        leftView.buttonView.tapped = { [weak self] in
            self?.leftViewTapped?()
        }
        
        rightView.buttonView.tapped = { [weak self] in
            self?.rightViewTapped?()
        }
        
        addNewViewCenterHorizontallyWithRightC.constant = -SearchConstants.fieldRightViewPadding
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? FieldLayoutAttributes {
            let percentageVisible = 1 - attributes.percentage
            
            let scalePercentageVisible = 0.5 + (0.5 * percentageVisible)
            leftView.findIconView.transform = CGAffineTransform(scaleX: scalePercentageVisible, y: scalePercentageVisible)
            rightView.clearIconView.transform = CGAffineTransform(scaleX: scalePercentageVisible, y: scalePercentageVisible)
            
            leftView.alpha = percentageVisible
            rightView.alpha = percentageVisible
            
            leftViewWidthC.constant = percentageVisible * SearchConstants.fieldLeftViewWidth
            rightViewWidthC.constant = percentageVisible * SearchConstants.fieldRightViewWidth
            
            baseViewLeftC.constant = SearchConstants.fieldBaseViewLeftPadding * attributes.percentage
            baseViewRightC.constant = SearchConstants.fieldBaseViewRightPadding * attributes.percentage
        }
    }
    
    func showAddNew(_ show: Bool, changeColorOnly: Bool) -> (() -> Void, () -> Void, () -> Void) {
        var setup = {} /// constraints
        var animationBlock = {}
        var completion = {} /// cleanup
        
        if changeColorOnly {
            animationBlock = { [weak self] in
                self?.contentView.backgroundColor = show ? .blue : SearchConstants.fieldBackgroundColor
            }
        } else {
            setup = { [weak self] in
                if show { /// keep plus button centered
                    self?.addNewViewCenterHorizontallyWithRightC.isActive = false
                    self?.addNewViewCenterHorizontallyWithSuperview.isActive = true
                } else { /// animate plus button to the right
                    self?.addNewViewCenterHorizontallyWithSuperview.isActive = false
                    self?.addNewViewCenterHorizontallyWithRightC.isActive = true
                }
            }
            
            animationBlock = { [weak self] in
                if show { /// show the plus
                    self?.addNewView.transform = .identity.rotated(by: 135.degreesToRadians)
                    self?.textField.alpha = 0
                    self?.leftView.buttonView.alpha = 0
                    self?.rightView.buttonView.alpha = 0
                    self?.contentView.backgroundColor = .blue
                } else { /// hide the plus, go to normal
                    self?.addNewView.transform = .identity
                    self?.textField.alpha = 1
                    self?.leftView.buttonView.alpha = 1
                    self?.contentView.backgroundColor = SearchConstants.fieldBackgroundColor
                }
                
                self?.baseView.layoutIfNeeded()
            }
            
            completion = { [weak self] in
                if show { /// show the plus
                    self?.rightView.buttonView.alpha = 0
                    self?.addNewView.alpha = 1
                } else { /// hide the plus
                    self?.rightView.buttonView.alpha = 1
                    self?.addNewView.alpha = 0
                }
            }
        }
        
        return (setup, animationBlock, completion)
    }
}

extension SearchFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            updateField {
                $0.text.value = .string(updatedText)
            }
            
            if updatedText.isEmpty {
                rightView.clearIconView.setState(.hidden, animated: true)
            } else {
                rightView.clearIconView.setState(.clear, animated: true)
            }
        }
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
