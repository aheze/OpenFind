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
    static var minCellWidth = CGFloat(80)
    static var thumbnailSize: CGSize = {
        let scale = UIScreen.main.scale
        let length = minCellWidth * 3 / 2 /// slightly clearer
        let thumbnailSize = CGSize(width: length * scale, height: minCellWidth * scale)
        return thumbnailSize
    }()

}

/// constants for the square cell
enum PhotosCellConstants {
    static var starTintColor = UIColor.white
    static var starFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static var starLeftPadding = CGFloat(5)
    static var starBottomPadding = CGFloat(5)
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
}
