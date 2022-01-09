//
//  SearchConfiguration.swift
//  SearchBar
//
//  Created by Zheng on 10/15/21.
//

import UIKit

struct SearchConfiguration: Equatable {
    var cellHeight = CGFloat(60)
    var cellSpacing = CGFloat(8)
    
    /// padding on the left and right at edge cells
    var sidePadding = CGFloat(16)
    
    /// extra padding to show nearby cells
    var sidePeekPadding = CGFloat(48)
    
    var fieldCornerRadius = CGFloat(16)
    var fieldBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    var fieldHighlightedBackgroundColor = UIColor(hex: 0x007eef)
    var fieldFont = UIFont.preferredFont(forTextStyle: .title1)
    var fieldFontColor = UIColor.white
    var fieldTintColor = UIColor.white /// tint of the cursor
    
    /// horizontal padding within cell, only when left and right view are hidden
    var fieldBaseViewRightPadding = CGFloat(12)
    var fieldBaseViewLeftPadding = CGFloat(12)
    
    /// vertical padding within cell
    var fieldBaseViewTopPadding = CGFloat(0)
    var fieldBaseViewBottomPadding = CGFloat(0)
    
    var fieldLeftViewWidth = CGFloat(48)
    var fieldLeftViewPadding = CGFloat(6) /// padding on the left and right
    var fieldRightViewWidth = CGFloat(48)
    var fieldRightViewPadding = CGFloat(6)
    
    var clearIconLength = CGFloat(22)
    var clearBackgroundColor = UIColor.white.withAlphaComponent(0.05)
    var clearImageColor = UIColor.white.withAlphaComponent(0.75)
    
    var addWordFieldHuggingWidth = CGFloat(24)
    var addWordFieldSnappingFactor = CGFloat(0.25) /// percent of screen width needed to swipe left
    
    var addTextPlaceholder = "Find anything"
    var minimumHuggingWidth = CGFloat(36)
    
    var keyboardAppearance = UIKeyboardAppearance.dark
    
    var showBackground = true
    var backgroundTopPadding = CGFloat(10)
    var backgroundBottomPadding = CGFloat(16)
    
    static var camera: Self = {
        var configuration = SearchConfiguration()
        return configuration
    }()
    
    static var lists: Self = {
        var configuration = SearchConfiguration(
            cellHeight: 44,
            cellSpacing: 8,
            sidePadding: 16,
            sidePeekPadding: 30,
            fieldCornerRadius: 12,
            fieldBackgroundColor: .systemBackground,
            fieldHighlightedBackgroundColor: UIColor(hex: 0x007eef).withAlphaComponent(0.2),
            fieldFont: UIFont.preferredFont(forTextStyle: .title3),
            fieldFontColor: .label,
            fieldTintColor: UIColor(hex: 0x007eef),
            fieldBaseViewRightPadding: 10,
            fieldBaseViewLeftPadding: 10,
            fieldBaseViewTopPadding: 0,
            fieldBaseViewBottomPadding: 0,
            fieldLeftViewWidth: 36,
            fieldLeftViewPadding: 4,
            fieldRightViewWidth: 36,
            fieldRightViewPadding: 4,
            clearIconLength: 18,
            clearBackgroundColor: .label.withAlphaComponent(0.05),
            clearImageColor: .label.withAlphaComponent(0.75),
            addWordFieldHuggingWidth: 20,
            addWordFieldSnappingFactor: 0.25,
            addTextPlaceholder: "Find lists",
            minimumHuggingWidth: 30,
            keyboardAppearance: UIKeyboardAppearance.default,
            showBackground: false,
            backgroundTopPadding: 2,
            backgroundBottomPadding: 16
        )
        return configuration
    }()
}
