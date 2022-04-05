//
//  SettingsConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsConstants {
    static var sidePadding = CGFloat(20)
    static var sectionCornerRadius = CGFloat(12)
    static var sectionSpacing = CGFloat(20)
    static var iconSize = CGSize(width: 28, height: 28)
    static var iconCornerRadius = CGFloat(6)
    
    static var dividerHeight = CGFloat(0.3)
    static var dividerColor = UIColor.secondaryLabel.withAlphaComponent(0.2)
    
    
    static var descriptionFont = UIFont.preferredFont(forTextStyle: .footnote)
    static var iconFont = UIFont.preferredCustomFont(forTextStyle: .footnote, weight: .semibold)
    
    static var rowInsets = EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
}
