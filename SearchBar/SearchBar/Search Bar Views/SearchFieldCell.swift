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
    
    @IBOutlet weak var addNewView: UIView!
    @IBOutlet weak var addNewViewCenterHorizontallyWithSuperview: NSLayoutConstraint!
    @IBOutlet weak var addNewViewCenterHorizontallyWithRightC: NSLayoutConstraint!
    @IBOutlet weak var addNewViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var addNewViewHeightC: NSLayoutConstraint!
    @IBOutlet weak var addNewImageView: UIImageView!
    
    
    
    
    var fieldChanged: ((Field) -> Void)?
    
    /// set field from datasource
    func setField(_ field: Field) {
        self.field = field
        self.textField.text = field.value.getText()
    }
    
    func updateField(_ makeChangesTo: ((inout Field) -> Void)) {
        makeChangesTo(&field)
        self.fieldChanged?(field)
    }
    
    private var field = Field(value: .string("")) {
        didSet {
            switch field.value {
            case .string(_):
                break
            case .list(_):
                break
            case .addNew:
                let (_, animations, completion) = showAddNew(true, changeColorOnly: false)
                animations()
                completion()
                return
            }
            let (_, animations, completion) = showAddNew(false, changeColorOnly: false)
            animations()
            completion()
        }
    }
    
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
        
        addNewViewWidthC.constant = Constants.fieldIconLength
        addNewViewHeightC.constant = Constants.fieldIconLength
        
        leftViewWidthC.constant = 0
        rightViewWidthC.constant = 0
        
//        leftView.tapped = { [weak self] in
//            print("Tap!")
//        }
        
        
        let image = UIImage(systemName: "xmark")
        let configuration = UIImage.SymbolConfiguration(font: Constants.fieldFont)
        addNewImageView.preferredSymbolConfiguration = configuration
        addNewImageView.image = image
        
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
    
    func showAddNew(_ show: Bool, changeColorOnly: Bool) -> (() -> Void, () -> Void, () -> Void) {
        
        var setup = { } /// constraints
        var animationBlock = { }
        var completion = { } /// cleanup
        
        if changeColorOnly {
            animationBlock = { [weak self] in
                self?.contentView.backgroundColor = show ? .blue : Constants.fieldBackgroundColor
            }
        } else {
            setup = { [weak self] in
                
                if show { /// keep plus button centered
                    self?.addNewViewCenterHorizontallyWithSuperview.isActive = true
                    self?.addNewViewCenterHorizontallyWithRightC.isActive = false
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
                    self?.contentView.backgroundColor = Constants.fieldBackgroundColor
                }
                
                self?.contentView.layoutIfNeeded()
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
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            updateField {
                $0.value = .string(updatedText)
            }

        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


