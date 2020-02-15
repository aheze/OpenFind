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
    func textFieldPressedReturn()
}
class GeneralTableCell: UITableViewCell, UITextFieldDelegate {
    
    
    
    var indexPath = 0 
    
    weak var changedTextDelegate: ChangedTextCell?
//    @IBOutlet weak var plusButton: UIButton!
//    @IBAction func plusPressed(_ sender: Any) {
//        print("PLUS PRESSED")
//        changedTextDelegate?.plusButtonPressed(indexPath: indexPath)
//    }
//
    @IBOutlet weak var matchTextField: UITextField!
    var cellFieldText = ""
    
    override var isSelected: Bool {
        didSet {
            print("HIGHLIGHT")
        }
    }
    
    
//    var hihilighted: Bool = false {
//        didSet {
//            print("HIHIHIH")
//        }
//    }
    @objc func onDidReceiveHighlight(_ notification: Notification)
    {
        print("NOTIFY")
//        if let data = notification.userInfo as? [Int: GeneralError] {
//            print("HAS DATA")
//            for key in data.keys {
//                if key == indexPath {
//
//
//                    switch data[key] {
//                    case .isDuplicate:
//                        print("dup")
//                    case .isEmptyString:
//                        print("emp")
//                    case .hasStartSpace:
//                        print("startSpace")
//                    case .hasEndSpace:
//                        print("endSpace")
//                    case .isSingleSpace:
//                        print("isSingleSpace")
//                    default:
//                        print("error")
//                    }
//
//                }
//            }
////            if let id = dict["image"] as? UIImage{
////                // do something with your image
////            }
//        }
//        if let data = notification.userInfo as? [String: Int]
//        {
//            for (name, score) in data
//            {
//                print("\(name) scored \(score) points!")
//            }
//        }
    }
    override func awakeFromNib() {
        //nc.addObserver(self, selector: #selector(userLoggedIn), name: Notification.Name("UserLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveHighlight(_:)), name: .hasToHighlight, object: nil)
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
        doneButton.layer.cornerRadius = 4
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
      print("Button tapped")
        contentView.endEditing(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("ENDED EDITING!!!!")
        changedTextDelegate?.textFieldEndedEditing(indexPath: indexPath, text: textField.text ?? "")
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("BEGIN!")
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

extension GeneralTableCell {
    
//    func showDescriptions() {
//         //maybe only space errors
//                    
//
////var hasEmptyMatch = 0
//let hasSingleSpaceMatch = singleSpaceWarning.count
//let hasStartSpace = startSpaceWarning.count
//let hasEndSpace = endSpaceWarning.count
//
//var singleMessage = ""
//switch hasSingleSpaceMatch {
//case 0:
//singleMessage = "One of you matches is an empty space"
//case 1:
//singleMessage = "One of you matches is an empty space"
//case 2:
//singleMessage = "Two of you matches is an empty space"
//default:
//singleMessage = "You have a lot of matches that are empty spaces"
//}
//
//var startMessage = ""
//switch hasStartSpace {
//case 0:
//startMessage = "One of you matches is an empty space"
//case 1:
//startMessage = "One of you matches is an empty space"
//case 2:
//startMessage = "Two of you matches is an empty space"
//default:
//startMessage = "You have a lot of matches that are empty spaces"
//}
//
//var endMessage = ""
//switch hasEndSpace {
//case 0:
//endMessage = "One of you matches is an empty space"
//case 1:
//endMessage = "One of you matches is an empty space"
//case 2:
//endMessage = "Two of you matches is an empty space"
//default:
//endMessage = "You have a lot of matches that are empty spaces"
//}
//
////        if (hasSingleSpaceMatch >= 1) {
////            print("asdasd")
////            var attributes = EKAttributes.topFloat
////            attributes.displayDuration = .infinity
////            attributes.entryInteraction = .absorbTouches
////            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
////            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
////            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
////            attributes.screenInteraction = .absorbTouches
////            showAnAlert = true
////            showButtonBarMessage(attributes: attributes, titleMessage: "Are you sure you want to have a match that is a space?", desc: "Probably not a good idea. Maybe check your matches?", leftButton: "Ignore and save", yesButton: "Ok, I'll go check")
////        } else {
////            print("NOTHING WRONG!")
////            //generalDelegate?.returnNewGeneral(nameOfList: name, desc: descriptionOfList, contentsOfList: contentsArray, interrupt: false)
////        }
//       
//    }
    
}


extension Notification.Name {
    static let hasToHighlight = Notification.Name("hasToHighlight")
    //static let didCompleteTask = Notification.Name("didCompleteTask")
    //static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}
