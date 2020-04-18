//
//  SwiftEntryKitTemplates.swift
//  Find
//
//  Created by Andrew on 2/6/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

enum EntryLocation {
    case top
    case middle
    case bottom
}
class SwiftEntryKitTemplates {
    static func displayHistoryHelp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        helpViewController.title = "Help"
        helpViewController.goDirectlyToUrl = true
        helpViewController.helpJsonKey = "HistoryFindHelpArray"
        helpViewController.directUrl = "https://zjohnzheng.github.io/FindHelp/History-HistoryControls.html"

        let navigationController = UINavigationController(rootViewController: helpViewController)
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.view.layer.cornerRadius = 10
        UINavigationBar.appearance().barTintColor = .black
        helpViewController.edgesForExtendedLayout = []
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
    
    func displaySEK(message: String, backgroundColor: UIColor, textColor: UIColor, location: EntryLocation = .top, duration: CGFloat = 0.7)  {
        
        var attributes = EKAttributes.topFloat
        
        switch location {
        case .top: attributes = EKAttributes.topFloat
        case .middle: attributes = EKAttributes.centerFloat
        case .bottom: attributes = EKAttributes.bottomFloat
        }
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = Double(duration)
        attributes.positionConstraints.size.height = .constant(value: 50)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 8, offset: .zero))
        //let font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        let contentView = UIView()
        contentView.backgroundColor = backgroundColor
        contentView.layer.cornerRadius = 8
        let subTitle = UILabel()
        subTitle.text = message
        subTitle.textColor = textColor
        contentView.addSubview(subTitle)
        subTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
}
