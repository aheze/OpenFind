//
//  PhotosGeneralExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

/// `CGFloat` should be the minimum cell width
extension CGFloat {
    /// get the number of columns and each column's width from available bounds + insets
    func getColumns(availableWidth: CGFloat) -> (Int, CGFloat) {
        
        let minCellWidth = self
        guard minCellWidth.isNormal else { return (0, 0) }
        
        let numberOfColumns = Int(availableWidth / minCellWidth)
        
        /// space between columns
        let columnSpacing = CGFloat(numberOfColumns - 1) * PhotosConstants.cellSpacing
        let columnWidth = (availableWidth - columnSpacing) / CGFloat(numberOfColumns)
        
        return (numberOfColumns, columnWidth)
    }

}

