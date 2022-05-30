//
//  PhotosConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

enum PhotosConstants {
    static var sidePadding = CGFloat(0)
    static var cellSpacing = CGFloat(2)

    /// how often to update results
    static var minimumResultsUpdateDuration = CGFloat(2.5)

    static var scanningCheckmarkWeight = UIFont.Weight.bold
    static var bottomPadding = CGFloat(16) /// extra padding, on top of the slider
}

enum PhotosHeaderConstants {
    static var font = UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold)
    static var labelLeftPadding = CGFloat(16)
    static var labelRightPadding = CGFloat(-36) /// between right of label and shadow image right
    static var labelTopPadding = CGFloat(8)
    static var labelBottomPadding = CGFloat(16) /// between label and bottom of header
}

/// constants for the square cell
enum PhotosCellConstants {
    static var starTintColor = UIColor.white
    static var starFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static var starLeftPadding = CGFloat(5)
    static var starBottomPadding = CGFloat(5)

    static var selectRightPadding = CGFloat(6)
    static var selectBottomPadding = CGFloat(6)

    static var selectedBackgroundColor = UIColor.white.withAlphaComponent(0.1)
}

enum PhotosSlidesConstants {
    static var infoHeightPercentageOfScreen = CGFloat(0.4)
    
    static var notesHeight = CGFloat(150)
}

enum PhotosResultsCellConstants {
    static var cornerRadius = CGFloat(12)

    /// corner radius of the image/left container.
    /// also referenced in `func imageCornerRadius(type: PhotoTransitionAnimatorType) -> CGFloat {`
    static var leftContainerCornerRadius = CGFloat(10)

    /// padding outside the stack view
    static var cellPadding = CGFloat(12)

    /// inside the stack view
    static var cellSpacing = CGFloat(10)

    static var titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static var titleTextColor = UIColor.label

    static var resultsFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static var resultsLabelTextColor = UIColor.secondaryLabel
    static var resultsLabelBackgroundColor = UIColor.secondarySystemBackground
    static var resultsLabelEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    static var descriptionFont = UIFont.preferredFont(forTextStyle: .body)
    static var descriptionTextColor = UIColor.label

    /// width of the image view
    static var leftContainerWidth = CGFloat(100)
    
    static var noteHeight = CGFloat(90)
    static var rightSpacing = CGFloat(12)
}
