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

    static var resultsCellCornerRadius = CGFloat(12)
    static var resultsCellImageCornerRadius = CGFloat(10)

    /// padding outside the stack view
    static var resultsCellPadding = CGFloat(12)

    /// inside the stack view
    static var resultsCellSpacing = CGFloat(10)

    static var resultsLabelEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
}
