//
//  GeneralTableviewCell.swift
//  Find
//
//  Created by Zheng on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol ChangedTextCell: class {
    //func plusButtonPressed(indexPath: Int)
    func textFieldEndedEditing(indexPath: Int, text: String)
    func textFieldStartedEditing(indexPath: Int)
    func textFieldChangedText(indexPath: Int, text: String)
    func cellPressedDoneButton()
    func textFieldPressedReturn()
}
class GeneralTableCell: UITableViewCell, UITextFieldDelegate {
    
    var isEmptyMatch = false
    
    var hasDuplicates = 0
    
    var isSingleSpace = false
    var hasStartSpace = false
    var hasEndSpace = false
    
    var thisRowHasErrors = false ///To toggle the invisible button
    
    var indexPath = 0
    
    var overlayView = UIView()
    var touchedView = false
    
    
    
    weak var changedTextDelegate: ChangedTextCell?
    @IBOutlet weak var warningButton: UIButton!
    
    @IBAction func warningPressed(_ sender: Any) {
        print("Warning Pressed")
        
        if thisRowHasErrors == false {
            matchTextField.becomeFirstResponder()
        } else {
            showDescriptions()
        }
        
    }
    
    @IBOutlet weak var matchTextField: UITextField!
    var cellFieldText = ""
    
    override var isSelected: Bool {
        didSet {
            print("HIGHLIGHT")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reuse!")
        NotificationCenter.default.removeObserver(self)
    }
    
//    override func viewWill
    @objc func onDidReceiveEmptyString(_ notification: Notification) {
       // print("NOTIFY, empty")
        if let data = notification.userInfo as? [Int: [Int]] {
            print("Recieved Empty String Data: \(data)")
            if let errorArray = data[0] {
                if errorArray.contains(indexPath) {
                    isEmptyMatch = true
                    thisRowHasErrors = true
                }
            }
        }
    }
    @objc func onDidReceiveStringErrors(_ notification: Notification) {
      //  print("recieve string errors")
       // print("Errors? \(notification.userInfo)")
        if let data = notification.userInfo as? [String: [Int]] {
            print("Space error data: \(data)")
             
            var isSingleSoStop = false
            for singleError in data["Single"] ?? [-1] {
                if singleError == indexPath {
                    isSingleSpace = true
                    thisRowHasErrors = true
                    isSingleSoStop = true
                }
            }
            if isSingleSoStop == false {
                for startError in data["Start"] ?? [-1] {
                    if startError == indexPath {
                        hasStartSpace = true
                        thisRowHasErrors = true
                    }
                }
                for endError in data["End"] ?? [-1] {
                    if endError == indexPath {
                        hasEndSpace = true
                        thisRowHasErrors = true
                    }
                }
            }
            
            
        }
    }
    @objc func onDupErrors(_ notification: Notification) {
      //  print("receive highlight string errors")
       // print("Errors? \(notification.userInfo)")
        if let data = notification.userInfo as? [String: [Int]] {
            print("Received duplicate data: \(data)")
            for duplicateString in data.keys {
                for arrayOfErrorRow in data[duplicateString]! {
                    
                    if arrayOfErrorRow == indexPath {
                        hasDuplicates += 1
                        thisRowHasErrors = true
                    }
                    
                }
            }
            
            //showDescriptions()
            
            
          //  print("HAS DATA")
         //   print("data: \(data)")
        }
    }
    
    func animateDupSlide() {
        overlayView.snp.remakeConstraints{ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(contentView.frame.size.width)
        }
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = 1
            self.contentView.layoutIfNeeded()
        }
        //overlayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
    }
    func animateDupRetreat() {
        overlayView.snp.remakeConstraints{ (make) in
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
    
    @objc func onHighlightRowErrors(_ notification: Notification) {
        //print("receive highlight string errors")
        //print("Errors? \(notification.userInfo)")
        animateDupRetreat()
        var arrayOfIndexes = [Int]()
        if let data = notification.userInfo as? [String: [Int]] {
            for singleDup in data {
                for errorIndex in singleDup.value {
                    arrayOfIndexes.append(errorIndex)
                }
            }
            print(arrayOfIndexes)
            if arrayOfIndexes.contains(indexPath) {
                animateDupSlide()
            }
        }
    }
    
    @objc func onAddRow(_ notification: Notification) {
      //  print("receive highlight string errors")
       // print("Errors? \(notification.userInfo)")
        if let data = notification.userInfo as? [Int: Int] {
            if indexPath >= data[0]! {
                indexPath += 1
            }
          //  print("HAS DATA")
         //   print("data: \(data)")
        }
    }
    
    @objc func onDeleteRow(_ notification: Notification) {
      //  print("receive highlight string errors")
       // print("Errors? \(notification.userInfo)")
        print("DELETE")
        if let data = notification.userInfo as? [Int: Int] {
            if indexPath >= data[0]! + 1 {
                indexPath -= 1
            }
          //  print("HAS DATA")
         //   print("data: \(data)")
        }
    }
    
    
    
//    @objc func onDidReceiveStartString(_ notification: Notification) {
//        print("Start string")
//        if let data = notification.userInfo as? [Int: [Int]] {
//            print("HAS DATA")
//        }
//    }
//    @objc func onDidReceiveEndString(_ notification: Notification) {
//        print("end string")
//        if let data = notification.userInfo as? [Int: [Int]] {
//            print("HAS DATA")
//        }
//    }
//    @objc func onDidReceiveSingleString(_ notification: Notification) {
//        print("is single string")
//        if let data = notification.userInfo as? [Int: [Int]] {
//            print("HAS DATA")
//        }
//    }
    override func awakeFromNib() {
        
        
        contentView.insertSubview(overlayView, at: 0)
        overlayView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        overlayView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        overlayView.alpha = 0
        
        //matchTextField.setLeftPaddingPoints(10)
        //nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveEmptyString), name: .hasEmptyString, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveStringErrors), name: .hasGeneralSpaces, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDupErrors), name: .hasDuplicates, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHighlightRowErrors), name: .shouldHighlightRows, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeleteRow), name: .deleteRowAt, object: nil)
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAddRow), name: .addedRowAt, object: nil)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveStartString), name: .hasStartSpace, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveEndString), name: .hasEndSpace, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveSingleString), name: .hasSingleSpace, object: nil)
        
        super.awakeFromNib()
        matchTextField.delegate = self
        let inputAView = UIView()
//        inputAView.snp.makeConstraints { (make) in
//            make.height.equalTo(50)
//        }
        inputAView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 50)
        inputAView.backgroundColor = UIColor(named: "Gray2")
        let doneButton = UIButton()
        inputAView.addSubview(doneButton)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        doneButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        doneButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        doneButton.layer.cornerRadius = 6
        //doneButton.frame.size.width = CGFloat(26)
        
        doneButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
            make.width.equalTo(60)
        }
        
        
        doneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        matchTextField.inputAccessoryView = inputAView
//        if indexPath == 0 {
//            plusButton.isHidden = true
//        }
    }
    
    
    
    @objc func buttonAction(sender: UIButton!) {
      //print("Button tapped")
        changedTextDelegate?.cellPressedDoneButton()
        contentView.endEditing(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
     //   print("ENDED EDITING!!!!")
        changedTextDelegate?.textFieldEndedEditing(indexPath: indexPath, text: textField.text ?? "")
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
       // print("BEGIN!")
        animateDupRetreat()
        changedTextDelegate?.textFieldStartedEditing(indexPath: indexPath)
        //touchedView = true
        
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

extension GeneralTableCell {
    
    func showWarningButtons() {
        
        
        
    }
    func showDescriptions() {
        print("showing descriptions")
        print(isEmptyMatch)
        
        print(hasDuplicates)
        
        print(isSingleSpace)
        print(hasStartSpace)
        print(hasEndSpace)
        
        if isEmptyMatch == true {
            
        }
         //maybe only space errors

        //var hasEmptyMatch = 0
//        let hasSingleSpaceMatch = singleSpaceWarning.count
//        let hasStartSpace = startSpaceWarning.count
//        let hasEndSpace = endSpaceWarning.count
//
//        var singleMessage = ""
//        switch hasSingleSpaceMatch {
//        case 0:
//        singleMessage = "One of you matches is an empty space"
//        case 1:
//        singleMessage = "One of you matches is an empty space"
//        case 2:
//        singleMessage = "Two of you matches is an empty space"
//        default:
//        singleMessage = "You have a lot of matches that are empty spaces"
//        }
//
//        var startMessage = ""
//        switch hasStartSpace {
//        case 0:
//        startMessage = "One of you matches is an empty space"
//        case 1:
//        startMessage = "One of you matches is an empty space"
//        case 2:
//        startMessage = "Two of you matches is an empty space"
//        default:
//        startMessage = "You have a lot of matches that are empty spaces"
//        }
//
//        var endMessage = ""
//        switch hasEndSpace {
//        case 0:
//        endMessage = "One of you matches is an empty space"
//        case 1:
//        endMessage = "One of you matches is an empty space"
//        case 2:
//        endMessage = "Two of you matches is an empty space"
//        default:
//        endMessage = "You have a lot of matches that are empty spaces"
//        }

        //        if (hasSingleSpaceMatch >= 1) {
        //            print("asdasd")
        //            var attributes = EKAttributes.topFloat
        //            attributes.displayDuration = .infinity
        //            attributes.entryInteraction = .absorbTouches
        //            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        //            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        //            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        //            attributes.screenInteraction = .absorbTouches
        //            showAnAlert = true
        //            showButtonBarMessage(attributes: attributes, titleMessage: "Are you sure you want to have a match that is a space?", desc: "Probably not a good idea. Maybe check your matches?", leftButton: "Ignore and save", yesButton: "Ok, I'll go check")
        //        } else {
        //            print("NOTHING WRONG!")
        //            //generalDelegate?.returnNewGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contentsArray, interrupt: false)
        //        }
       
    }
    
}


extension Notification.Name {
    
    static let hasEmptyString = Notification.Name("hasEmptyString")
    static let hasGeneralSpaces = Notification.Name("hasGeneralSpaces")
    static let hasDuplicates = Notification.Name("hasDuplicates")
    
    static let shouldHighlightRows = Notification.Name("shouldHighlightRows")
    
    static let addedRowAt = Notification.Name("addedRowAt")
    static let deleteRowAt = Notification.Name("deleteRowAt")
    //static let delete = Notification.Name("hasGeneralSpaces")
    
//    static let hasStartSpace = Notification.Name("hasStartSpace")
//    static let hasEndSpace = Notification.Name("hasStartSpace")
//    static let hasSingleSpace = Notification.Name("hasSingleSpace")
    
    
    //static let didCompleteTask = Notification.Name("didCompleteTask")
    //static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
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
//    override func clearButton(forBounds bounds: CGRect) -> CGRect {
//        super.editingRect(forBounds: bounds)
//
//        return CGRect(rect, -5, 0);
//    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds)
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
