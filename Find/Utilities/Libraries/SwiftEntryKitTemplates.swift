//
//  SwiftEntryKitTemplates.swift
//  Find
//
//  Created by Andrew on 2/6/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import SwiftEntryKit
import UIKit

enum EntryLocation {
    case top
    case middle
    case bottom
}

class SwiftEntryKitTemplates {
    func displaySEK(message: String, backgroundColor: UIColor, textColor: UIColor, location: EntryLocation = .top, duration: CGFloat = 0.7) {
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
        attributes.positionConstraints.size.height = .intrinsic
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 8, offset: .zero))
        let contentView = UIView()
        contentView.backgroundColor = backgroundColor
        contentView.layer.cornerRadius = 8
        let subTitle = UILabel()
        subTitle.numberOfLines = 0
        subTitle.textAlignment = .center
        subTitle.text = message
        subTitle.textColor = textColor
        contentView.addSubview(subTitle)
        subTitle.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}

enum SEKColor {
    enum Gray {
        static let a800 = EKColor(rgb: 0x424242)
        static let light = EKColor(red: 230, green: 230, blue: 230)
    }
}
