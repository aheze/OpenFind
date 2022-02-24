//
//  PhotosVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/**
 The results collection view, which should present slides as finding slides
 */

extension PhotosViewController {
    func showResults(_ show: Bool) {
        if show {
            resultsCollectionView.alpha = 1
            collectionView.alpha = 0
        } else {
            resultsCollectionView.alpha = 0
            collectionView.alpha = 1
        }
    }
    
    /// get the text to show in the cell's text view
    func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }.joined(separator: "\n")
        return string
    }
}
