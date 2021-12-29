//
//  GeneralTableviewCell.swift
//  Find
//
//  Created by Zheng on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol ChangedTextCell: class {
    func textFieldEndedEditing(indexPath: Int, text: String)
    func textFieldStartedEditing(indexPath: Int)
    func textFieldChangedText(indexPath: Int, text: String)
    func cellPressedDoneButton()
    func textFieldPressedReturn()
}

class GeneralTableCell: UITableViewCell, UITextFieldDelegate {
    var indexPath = 0
    
    var overlayView = UIView()
    var doneButton: UIButton?
    
    weak var changedTextDelegate: ChangedTextCell?
    
    var deletePressed: (() -> Void)?
    @IBOutlet var deleteButton: UIButton!
    @IBAction func deletePressed(_ sender: Any) {
        deletePressed?()
    }
    
    @IBOutlet var matchTextField: UITextField!
    var cellFieldText = ""
  
    func animateDupSlide() {
        overlayView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(contentView.frame.size.width)
        }
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = 1
            self.contentView.layoutIfNeeded()
        }
    }

    func animateDupRetreat() {
        overlayView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = 0
            self.contentView.layoutIfNeeded()
        }
    }
   
    override func awakeFromNib() {
        matchTextField.returnKeyType = .next
        contentView.insertSubview(overlayView, at: 0)
        overlayView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        overlayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        overlayView.alpha = 0
        
        super.awakeFromNib()
        matchTextField.delegate = self
        
        let toolbarInputView = UIView()
        toolbarInputView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 50)
        toolbarInputView.backgroundColor = UIColor(named: "Gray2")
        
        let doneButton = UIButton()
        toolbarInputView.addSubview(doneButton)
        
        let done = NSLocalizedString("done", comment: "Multipurpose def=Done")
        
        doneButton.setTitle(done, for: .normal)
        doneButton.titleEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        doneButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        doneButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        doneButton.layer.cornerRadius = 6
        doneButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
            make.width.equalTo(60)
        }
        
        doneButton.isAccessibilityElement = true
        doneButton.accessibilityLabel = "Done"
        doneButton.accessibilityHint = "Dismiss the keyboard"
        
        doneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.doneButton = doneButton
        
        matchTextField.inputAccessoryView = toolbarInputView
    }
    
    @objc func buttonAction(sender: UIButton!) {
        changedTextDelegate?.cellPressedDoneButton()
        contentView.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        changedTextDelegate?.textFieldEndedEditing(indexPath: indexPath, text: textField.text ?? "")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateDupRetreat()
        changedTextDelegate?.textFieldStartedEditing(indexPath: indexPath)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changedTextDelegate?.textFieldPressedReturn()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        changedTextDelegate?.textFieldChangedText(indexPath: indexPath, text: updatedString ?? "Something went wrong...")
        
        return true
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds)
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
