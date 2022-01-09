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
    var textChanged: ((String) -> Void)?

    func activate(_ isActive: Bool) {
        if isActive {
            triggerButton.isEnabled = false
        } else {
            triggerButton.isEnabled = true
        }
    }
    
    var configuration = SearchConfiguration()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /// Needed for some reason sometimes
        triggerButton.setTitle("", for: .normal)
        
        contentView.backgroundColor = configuration.fieldBackgroundColor
        contentView.layer.cornerRadius = configuration.fieldCornerRadius
        
        textField.delegate = self
        textField.font = configuration.fieldFont
        textField.textColor = .white
        
        textField.attributedPlaceholder = NSAttributedString(
            string: configuration.addTextPlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        
        baseViewTopC.constant = configuration.fieldBaseViewTopPadding
        baseViewRightC.constant = configuration.fieldBaseViewRightPadding
        baseViewBottomC.constant = configuration.fieldBaseViewBottomPadding
        baseViewLeftC.constant = configuration.fieldBaseViewLeftPadding
        
        addNewViewWidthC.constant = configuration.clearIconLength
        addNewViewHeightC.constant = configuration.clearIconLength
        
        leftViewWidthC.constant = 0
        rightViewWidthC.constant = 0
        
        leftView.configuration = configuration
        rightView.configuration = configuration
        
        leftView.buttonView.tapped = { [weak self] in
            self?.leftViewTapped?()
        }
        
        rightView.buttonView.tapped = { [weak self] in
            self?.rightViewTapped?()
        }
        
        addNewViewCenterHorizontallyWithRightC.constant = -configuration.fieldRightViewPadding
        
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
            
            leftViewWidthC.constant = percentageVisible * configuration.fieldLeftViewWidth
            rightViewWidthC.constant = percentageVisible * configuration.fieldRightViewWidth
            
            if attributes.beingDeleted {
                baseViewLeftC.constant = 0
                baseViewRightC.constant = 0
            } else {
                baseViewLeftC.constant = configuration.fieldBaseViewLeftPadding * attributes.percentage
                baseViewRightC.constant = configuration.fieldBaseViewRightPadding * attributes.percentage
            }
        }
    }
    
    func loadConfiguration(showAddNew isAddNew: Bool) {
        if isAddNew {
            let (setup, animations, completion) = showAddNew(true)
            setup()
            animations()
            completion()
            contentView.backgroundColor = configuration.fieldBackgroundColor
        } else {
            let (setup, animations, completion) = showAddNew(false)
            setup()
            animations()
            completion()
        }
    }
    
    func showAddNew(_ show: Bool) -> (() -> Void, () -> Void, () -> Void) {
        var setup = {} /// constraints
        var animationBlock = {}
        var completion = {} /// cleanup
        
        setup = { [weak self] in
            guard let self = self else { return }
            if show { /// keep plus button centered
                self.addNewViewCenterHorizontallyWithRightC.isActive = false
                self.addNewViewCenterHorizontallyWithSuperview.isActive = true
                self.addNewIconView.setState(.delete, animated: false)
                self.rightView.clearIconView.setState(.delete, animated: false)
            } else { /// animate plus button to the right
                self.addNewViewCenterHorizontallyWithSuperview.isActive = false
                self.addNewViewCenterHorizontallyWithRightC.isActive = true
            }
        }
        
        animationBlock = { [weak self] in
            guard let self = self else { return }
            
            if show { /// show the plus
                
                /// shrink at first
                self.addNewView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).rotated(by: 135.degreesToRadians)
                self.textField.alpha = 0
                self.leftView.buttonView.alpha = 0
                self.rightView.buttonView.alpha = 0
            } else { /// hide the plus, go to normal
                self.addNewView.transform = .identity
                self.textField.alpha = 1
                self.leftView.buttonView.alpha = 1
                self.contentView.backgroundColor = self.configuration.fieldBackgroundColor
            }
            
            self.baseView.layoutIfNeeded()
        }
        
        completion = { [weak self] in
            guard let self = self else { return }
            if show { /// show the plus
                self.rightView.buttonView.alpha = 0
                self.addNewView.alpha = 1
            } else { /// hide the plus
                self.rightView.buttonView.alpha = 1
                self.addNewView.alpha = 0
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
            textChanged?(updatedText)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
