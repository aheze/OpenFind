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
