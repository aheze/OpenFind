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
class HistorySelectorView: UIView, ChangeNumberOfSelected, ChangeAttributes {
    
    func getRect() -> CGRect {
//        print("origFrame: \(shareButton.frame)")
        let rect = stackView.convert(shareButton.frame, to: contentView)
        let finalRect = self.contentView.convert(rect, to: nil)
//        print("rect float: \(rect)")
//        print("new: \(finalRect)")
        return finalRect
    }
    func changeFloat(to: String) {
        
        switch to {
        case "Fill Heart":
            let newImage = UIImage(systemName: "heart.fill")
            heartButton.setImage(newImage, for: .normal)
        case "Unfill Heart":
            let newImage = UIImage(systemName: "heart")
        heartButton.setImage(newImage, for: .normal)
        case "Enable":
            findButton.isEnabled = true
            heartButton.isEnabled = true
            deleteButton.isEnabled = true
            cacheButton.isEnabled = true
            shareButton.isEnabled = true
        case "Disable":
            findButton.isEnabled = false
            heartButton.isEnabled = false
            deleteButton.isEnabled = false
            cacheButton.isEnabled = false
            shareButton.isEnabled = false
        case "Cached":
            cacheButton.setImage(UIImage(named: "SelectCached"), for: .normal)
        case "NotCached":
            cacheButton.setImage(UIImage(named: "SelectNotCached"), for: .normal)
        default:
            print("WRONG STRING....")
        }
    }
    
    func changeLabel(to: Int) {
        if to == 1 {
            photoSelectLabel.fadeTransition(0.1)
            photoSelectLabel.text = "\(to) Photo Selected"
        } else {
            photoSelectLabel.fadeTransition(0.1)
            photoSelectLabel.text = "\(to) Photos Selected"
        }
        
    }

    @IBOutlet weak var photoSelectLabel: UILabel!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var contentView: UIView!
    
    
    @IBAction func findPressed(_ sender: UIButton) {
        print("find")
        buttonPressedDelegate?.floatButtonPressed(button: "find")
    }
    
    @IBAction func heartPressed(_ sender: UIButton) {
        print("heart")
        buttonPressedDelegate?.floatButtonPressed(button: "heart")
        
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        print("delete")
        buttonPressedDelegate?.floatButtonPressed(button: "delete")
    }

    @IBAction func cachePressed(_ sender: Any) {
        buttonPressedDelegate?.floatButtonPressed(button: "cache")
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        buttonPressedDelegate?.floatButtonPressed(button: "share")
//        buttonPressedDelegate?.floatButtonPressed(button: "help")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
//        helpViewController.title = "Help"
//        helpViewController.helpJsonKey = "HistoryFindHelpArray"
//        helpViewController.goDirectlyToUrl = true
//        helpViewController.directUrl = "https://zjohnzheng.github.io/FindHelp/History-HistoryControls.html"
//
//        let navigationController = UINavigationController(rootViewController: helpViewController)
//        navigationController.view.backgroundColor = UIColor.clear
//        navigationController.navigationBar.tintColor = UIColor.white
//        navigationController.navigationBar.prefersLargeTitles = true
//
//        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.configureWithOpaqueBackground()
//        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        navBarAppearance.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//        navigationController.navigationBar.standardAppearance = navBarAppearance
//        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
//        navigationController.view.layer.cornerRadius = 10
//        UINavigationBar.appearance().barTintColor = .black
//        helpViewController.edgesForExtendedLayout = []
//        var attributes = EKAttributes.centerFloat
//        attributes.displayDuration = .infinity
//        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
//        attributes.entryBackground = .color(color: .white)
//        attributes.screenInteraction = .absorbTouches
//        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
//        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
    weak var buttonPressedDelegate: ButtonPressed?
    
    @IBOutlet weak var stackView: UIStackView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        
        Bundle.main.loadNibNamed("HistorySelect", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
    }
}
