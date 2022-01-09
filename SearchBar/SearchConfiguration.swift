//
//  SearchConfiguration.swift
//  SearchBar
//
//  Created by Zheng on 10/15/21.
//

import UIKit

struct SearchConfiguration {
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
    
    var addWordFieldHuggingWidth = CGFloat(24)
    var addWordFieldSnappingFactor = CGFloat(0.25) /// percent of screen width needed to swipe left
    var addWordFieldSidePadding = CGFloat(0)
    
    var addTextPlaceholder = "Find anything"
    var minimumHuggingWidth = CGFloat(36)
}
