//
//  Constants.swift
//  SearchBar
//
//  Created by Zheng on 10/15/21.
//

import UIKit

struct Constants {
    static var cellHeight = CGFloat(64)
    static var sidePadding = CGFloat(16)
    static var sidePeekPadding = CGFloat(64) /// extra padding to show nearby cells
    static var cellSpacing = CGFloat(8)
    static var fieldFont = UIFont.preferredFont(forTextStyle: .title1)
    
    static var fieldBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    static var fieldCornerRadius = CGFloat(16)
    
    static var fieldBaseViewTopPadding = CGFloat(8)
    static var fieldBaseViewRightPadding = CGFloat(12)
    static var fieldBaseViewBottomPadding = CGFloat(6)
    static var fieldBaseViewLeftPadding = CGFloat(12)
    
    static var fieldTextSidePadding = CGFloat(0)
    
    static var fieldLeftViewWidth = CGFloat(40)
    static var fieldRightViewWidth = CGFloat(40)
    
    static var addWordFieldHuggingWidth = CGFloat(24)
    static var addWordFieldSnappingFactor = CGFloat(0.25) /// percent of screen width needed to swipe left
    static var addWordFieldAntiFlickerPadding = CGFloat(2)
    
    static var fieldIconLength = CGFloat(32)
    
    static var addTextPlaceholder = "Type here to find"
}
