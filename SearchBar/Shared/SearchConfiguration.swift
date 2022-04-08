//
//  SearchConfiguration.swift
//  SearchBar
//
//  Created by Zheng on 10/15/21.
//

import UIKit

struct SearchConfiguration: Equatable {
    var cellHeight = CGFloat(60)
    var cellHeightLandscape = CGFloat(60) /// smaller cell height for camera. modify this later
    var cellSpacing = CGFloat(8)
    
    /// padding on the left and right at edge cells
    var sidePadding = CGFloat(16)
    
    /// extra padding to show nearby cells
    var sidePeekPadding = CGFloat(48)
    
    var fieldCornerRadius = CGFloat(16)
    var fieldBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    var fieldActiveBackgroundColor = UIColor.black.withAlphaComponent(0.5)
    var fieldHighlightedBackgroundColor = UIColor(hex: 0x007eef)
    var fieldFont = UIFont.preferredFont(forTextStyle: .title1)
    var fieldFontColor = UIColor.white
    var fieldTintColor = UIColor.white /// tint of the cursor
    var fieldListIconFont = UIFont.systemFont(ofSize: 19)
    
    /// horizontal padding within cell, only when left and right view are hidden
    var fieldBaseViewRightPadding = CGFloat(12)
    var fieldBaseViewLeftPadding = CGFloat(12)
    
    /// vertical padding within cell
    var fieldBaseViewTopPadding = CGFloat(0)
    var fieldBaseViewBottomPadding = CGFloat(0)
    
    var fieldLeftViewWidth = CGFloat(48)
    var fieldRightViewWidth = CGFloat(48)
    
    var fieldLeftIconViewPadding = CGFloat(4) /// padding on the left for the Find icon (for words)
    var fieldLeftImageViewPadding = CGFloat(3) /// padding on the left for the list image
    var fieldRightClearViewPadding = CGFloat(0) /// padding on the right of the clear icon
    
    var clearIconLength = CGFloat(22)
    var clearBackgroundColor = UIColor.white.withAlphaComponent(0.05)
    var clearImageColor = UIColor.white.withAlphaComponent(0.75)
    
    var addWordFieldHuggingWidth = CGFloat(24)
    var addWordFieldSnappingFactor = CGFloat(0.25) /// percent of screen width needed to swipe left
    
    var addTextPlaceholder = "Find Anything"
    var minimumHuggingWidth = CGFloat(36)
    
    var keyboardAppearance = UIKeyboardAppearance.dark
    
    var showBackground = true
    
    var barTopPadding = CGFloat(10)
    var barBottomPadding = CGFloat(16)
    
    var barTopPaddingLandscape = CGFloat(16)
    var barBottomPaddingLandscape = CGFloat(16)
    
    // MARK: - Popovers

    var popoverBackgroundBlurStyle = UIBlurEffect.Style.systemUltraThinMaterialDark
    var popoverBackgroundColor = UIColor(hex: 0x0070af).withAlphaComponent(0.5)
    var popoverButtonColor = UIColor.black.withAlphaComponent(0.5)
    var popoverTextColor = UIColor.white
    var popoverDividerColor = UIColor.white.withAlphaComponent(0.2)
    
    static var camera: Self = {
        var configuration = SearchConfiguration()
        return configuration
    }()
    
    static var lists: Self = {
        var configuration = SearchConfiguration(
            cellHeight: 44,
            cellHeightLandscape: 44,
            cellSpacing: 8,
            sidePadding: 16,
            sidePeekPadding: 30,
            fieldCornerRadius: 12,
            fieldBackgroundColor: .systemBackground,
            fieldActiveBackgroundColor: .systemBackground,
            fieldHighlightedBackgroundColor: UIColor(hex: 0x007eef).withAlphaComponent(0.2),
            fieldFont: UIFont.preferredFont(forTextStyle: .title3),
            fieldFontColor: .label,
            fieldTintColor: UIColor(hex: 0x007eef),
            fieldListIconFont: .preferredFont(forTextStyle: .body),
            fieldBaseViewRightPadding: 10,
            fieldBaseViewLeftPadding: 10,
            fieldBaseViewTopPadding: 0,
            fieldBaseViewBottomPadding: 0,
            fieldLeftViewWidth: 40,
            fieldRightViewWidth: 40,
            fieldLeftIconViewPadding: 4,
            fieldLeftImageViewPadding: 3,
            fieldRightClearViewPadding: 0,
            clearIconLength: 18,
            clearBackgroundColor: .label.withAlphaComponent(0.05),
            clearImageColor: .label.withAlphaComponent(0.75),
            addWordFieldHuggingWidth: 20,
            addWordFieldSnappingFactor: 0.25,
            addTextPlaceholder: "Find Lists",
            minimumHuggingWidth: 30,
            keyboardAppearance: UIKeyboardAppearance.default,
            showBackground: false,
            barTopPadding: 0,
            barBottomPadding: 16,
            barTopPaddingLandscape: 0,
            barBottomPaddingLandscape: 16,
            popoverBackgroundBlurStyle: .systemThinMaterial,
            popoverBackgroundColor: UIColor.systemBackground.withAlphaComponent(0.5),
            popoverButtonColor: UIColor.label.withAlphaComponent(0.05),
            popoverTextColor: UIColor.label,
            popoverDividerColor: UIColor.label.withAlphaComponent(0.2)
        )
        return configuration
    }()

    static var photos: Self = {
        var configuration = SearchConfiguration.lists
        configuration.fieldBackgroundColor = .secondarySystemBackground
        configuration.fieldActiveBackgroundColor = .systemBackground
        configuration.addTextPlaceholder = "Find Photos"
        return configuration
    }()
    
    static var photosSlides: Self = {
        var configuration = SearchConfiguration.photos
        configuration.addTextPlaceholder = "Find in Photo"
        return configuration
    }()
    
    static var icons: Self = {
        var configuration = SearchConfiguration.photos
        configuration.fieldActiveBackgroundColor = .secondarySystemBackground
        configuration.addTextPlaceholder = "Find Icons"
        return configuration
    }()
    
    static var settings: Self = {
        var configuration = SearchConfiguration.lists
        configuration.addTextPlaceholder = "Find Settings"
        configuration.sidePadding = 20
        configuration.sidePeekPadding = 36
        return configuration
    }()
}
