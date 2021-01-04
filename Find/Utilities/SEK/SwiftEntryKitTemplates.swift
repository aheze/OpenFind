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

struct SEKColor {
    struct BlueGray {
        static let c50 = EKColor(rgb: 0xeceff1)
        static let c100 = EKColor(rgb: 0xcfd8dc)
        static let c300 = EKColor(rgb: 0x90a4ae)
        static let c400 = EKColor(rgb: 0x78909c)
        static let c700 = EKColor(rgb: 0x455a64)
        static let c800 = EKColor(rgb: 0x37474f)
        static let c900 = EKColor(rgb: 0x263238)
    }
    
    struct Netflix {
        static let light = EKColor(rgb: 0x485563)
        static let dark = EKColor(rgb: 0x29323c)
    }
    
    struct Gray {
        static let a800 = EKColor(rgb: 0x424242)
        static let mid = EKColor(rgb: 0x616161)
        static let light = EKColor(red: 230, green: 230, blue: 230)
    }
    
    struct Purple {
        static let a300 = EKColor(rgb: 0xba68c8)
        static let a400 = EKColor(rgb: 0xab47bc)
        static let a700 = EKColor(rgb: 0xaa00ff)
        static let deep = EKColor(rgb: 0x673ab7)
    }
    
    struct BlueGradient {
        static let light = EKColor(red: 100, green: 172, blue: 196)
        static let dark = EKColor(red: 27, green: 47, blue: 144)
    }
    
    struct Yellow {
        static let a700 = EKColor(rgb: 0xffd600)
    }
    
    struct Teal {
        static let a700 = EKColor(rgb: 0x00bfa5)
        static let a600 = EKColor(rgb: 0x00897b)
    }
    
    struct Orange {
        static let a50 = EKColor(rgb: 0xfff3e0)
    }
    
    struct LightBlue {
        static let a700 = EKColor(rgb: 0x0091ea)
    }
    
    struct LightPink {
        static let first = EKColor(rgb: 0xff9a9e)
        static let last = EKColor(rgb: 0xfad0c4)
    }
}
