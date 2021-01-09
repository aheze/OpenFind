//
//  HistorySelector.swift
//  Find
//
//  Created by Andrew on 1/6/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol ButtonPressed: class {
    func floatButtonPressed(button: String)
}
//class HistorySelectorView: UIView, ChangeNumberOfSelected, ChangeAttributes {
//    
//    func getRect() -> CGRect {
//        let rect = stackView.convert(shareButton.frame, to: contentView)
//        let finalRect = self.contentView.convert(rect, to: nil)
//        return finalRect
//    }
//    func changeFloat(to: String) {
//        
//        switch to {
//        case "Fill Heart":
//            let newImage = UIImage(systemName: "heart.fill")
//            heartButton.setImage(newImage, for: .normal)
//        case "Unfill Heart":
//            let newImage = UIImage(systemName: "heart")
//        heartButton.setImage(newImage, for: .normal)
//        case "Enable":
//            findButton.isEnabled = true
//            heartButton.isEnabled = true
//            deleteButton.isEnabled = true
//            cacheButton.isEnabled = true
//            shareButton.isEnabled = true
//        case "Disable":
//            findButton.isEnabled = false
//            heartButton.isEnabled = false
//            deleteButton.isEnabled = false
//            cacheButton.isEnabled = false
//            shareButton.isEnabled = false
//        case "Cached":
//            cacheButton.setImage(UIImage(named: "SelectCached"), for: .normal)
//        case "NotCached":
//            cacheButton.setImage(UIImage(named: "SelectNotCached"), for: .normal)
//        default:
//            print("WRONG STRING....")
//        }
//    }
//    
//    func changeLabel(to number: Int) {
//        if number == 1 {
//            photoSelectLabel.fadeTransition(0.1)
//            let photoSelected = NSLocalizedString("photoSelected", comment: "HistorySelect def=Photo Selected")
//            photoSelectLabel.text = "\(number) \(photoSelected)"
//        } else {
//            photoSelectLabel.fadeTransition(0.1)
//            let photosSelected = NSLocalizedString("photosSelected", comment: "HistorySelect def=Photos Selected")
//            photoSelectLabel.text = "\(number) \(photosSelected)"
//        }
//        
//    }
//
//    @IBOutlet weak var photoSelectLabel: UILabel!
//    
//    @IBOutlet weak var findButton: UIButton!
//    @IBOutlet weak var heartButton: UIButton!
//    @IBOutlet weak var deleteButton: UIButton!
//    @IBOutlet weak var cacheButton: UIButton!
//    @IBOutlet weak var shareButton: UIButton!
//    
//    
//    @IBOutlet weak var contentView: UIView!
//    
//    
//    @IBAction func findPressed(_ sender: UIButton) {
//        buttonPressedDelegate?.floatButtonPressed(button: "find")
//    }
//    
//    @IBAction func heartPressed(_ sender: UIButton) {
//        buttonPressedDelegate?.floatButtonPressed(button: "heart")
//        
//    }
//    
//    @IBAction func deletePressed(_ sender: UIButton) {
//        buttonPressedDelegate?.floatButtonPressed(button: "delete")
//    }
//
//    @IBAction func cachePressed(_ sender: Any) {
//        buttonPressedDelegate?.floatButtonPressed(button: "cache")
//    }
//    
//    @IBAction func sharePressed(_ sender: Any) {
//        buttonPressedDelegate?.floatButtonPressed(button: "share")
//    }
//    weak var buttonPressedDelegate: ButtonPressed?
//    
//    @IBOutlet weak var stackView: UIStackView!
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUp()
//    }
//    
//    init() {
//        super.init(frame: .zero)
//        setUp()
//    }
//    private func setUp() {
//        clipsToBounds = true
//        layer.cornerRadius = 5
//        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
//        
//        Bundle.main.loadNibNamed("HistorySelect", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        cacheButton.imageView?.contentMode = .scaleAspectFill
//    }
//}
