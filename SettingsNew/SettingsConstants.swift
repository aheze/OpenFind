//
//  SettingsConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsConstants {
    
    /// insets around all content
    static var edgeInsets = EdgeInsets(top: 4, leading: 20, bottom: 20, trailing: 20)
    static var sectionCornerRadius = CGFloat(12)
    static var sectionSpacing = CGFloat(20)
    static var iconSize = CGSize(width: 28, height: 28)
    static var iconCornerRadius = CGFloat(6)
    
    static var headerBottomPadding = CGFloat(5)
    static var descriptionTopPadding = CGFloat(8)
    
    static var dividerHeight = CGFloat(0.3)
    static var dividerColor = UIColor.secondaryLabel.withAlphaComponent(0.2)
    
    /// spacing between icon and title
    static var rowIconTitleSpacing = CGFloat(12)
    
    static var descriptionFont = UIFont.preferredFont(forTextStyle: .footnote)
    static var iconFont = UIFont.preferredCustomFont(forTextStyle: .footnote, weight: .semibold)
    
    static var rowVerticalInsetsFromText = EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0)
    static var rowHorizontalInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
}
