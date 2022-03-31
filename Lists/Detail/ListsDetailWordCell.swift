//
//  ListsDetailWordCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsDetailWordCell: UITableViewCell {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewTopC: NSLayoutConstraint!
    @IBOutlet var stackViewRightC: NSLayoutConstraint!
    @IBOutlet var stackViewLeftC: NSLayoutConstraint!
    @IBOutlet var stackViewBottomC: NSLayoutConstraint!
    
    @IBOutlet var leftView: ButtonView!
    @IBOutlet var leftSelectionIconView: SelectionIconView!
    
    @IBOutlet var centerView: UIView!
    @IBOutlet var textField: PaddedTextField!
    
    @IBOutlet var rightView: UIView!
    @IBOutlet var rightDragHandleImageView: UIImageView!
    
    var leftViewTapped: (() -> Void)?
    
    /// text changed to the string #1, appended/replacement string is #2, should the textfield update?
    var textChanged: ((String, String) -> Bool)?
    var startedEditing: (() -> Void)?
    var finishedEditing: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            if let reorderControl = subview.subviews.first(where: { $0 is UIImageView }) {
                reorderControl.isHidden = true
            }
        }
        contentView.frame = bounds
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftView.backgroundColor = .clear
        leftSelectionIconView.configuration = .listsDetail
        leftView.tapped = { [weak self] in
            self?.leftViewTapped?()
        }
        
        rightDragHandleImageView.setIconFont(font: .preferredFont(forTextStyle: .title3))
        rightDragHandleImageView.image = UIImage(systemName: "line.3.horizontal")
        
        applyConstants()
        textField.delegate = self
    }
    
    func applyConstants() {
        let c = ListsDetailConstants.self
        
        textField.font = c.listRowWordFont
        textField.textColor = c.listRowWordTextColor
        textField.attributedPlaceholder = NSAttributedString(
            string: "Word",
            attributes: [
                NSAttributedString.Key.foregroundColor: c.listRowWordPlaceholderColor
            ]
        )
        textField.padding = c.listRowWordEdgeInsets
        
        stackViewTopC.constant = c.listRowContentEdgeInsets.top
        stackViewRightC.constant = c.listRowContentEdgeInsets.right
        stackViewLeftC.constant = c.listRowContentEdgeInsets.left
        stackViewBottomC.constant = c.listRowContentEdgeInsets.bottom
        
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = c.listRowWordCornerRadius
        centerView.backgroundColor = c.listRowWordBackgroundColor
    }
    
    var previousWord: (() -> Void)?
    @objc func previousTapped() {
        previousWord?()
    }
    
    var nextWord: (() -> Void)?
    @objc func nextTapped() {
        nextWord?()
    }
    
    var addWord: (() -> Void)?
    @objc func addTapped() {
        addWord?()
    }
}

extension ListsDetailWordCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if
            let text = textField.text,
            let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            return textChanged?(updatedText, string) ?? true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        finishedEditing?()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        startedEditing?()
    }
}
