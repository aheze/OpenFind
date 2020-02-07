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
    func displaySEK(message: String, backgroundColor: UIColor, textColor: UIColor, location: EntryLocation = .top)  {
        
        var attributes = EKAttributes.topFloat
        
        switch location {
        case .top: attributes = EKAttributes.topFloat
        case .middle: attributes = EKAttributes.centerFloat
        case .bottom: attributes = EKAttributes.bottomFloat
        }
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = 0.7
        attributes.positionConstraints.size.height = .constant(value: 50)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
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
