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
    /// `removeFromSuperview` is necessary to update the large title scrolling behavior
    func showResults(_ show: Bool) {
        if show {
            if resultsCollectionView.window == nil {
                view.addSubview(resultsCollectionView)
                resultsCollectionView.pinEdgesToSuperview()
            }
            collectionView.removeFromSuperview()
            updateNavigationBlur(with: resultsCollectionView)
        } else {
            if collectionView.window == nil {
                view.addSubview(collectionView)
                collectionView.pinEdgesToSuperview()
            }
            resultsCollectionView.removeFromSuperview()
            updateNavigationBlur(with: collectionView)
            model.resultsState = nil
        }
    }

    /// get the text to show in the cell's text view
    func getCellDescription(from descriptionLines: [FindPhoto.Line]) -> String {
        let topLines = descriptionLines.prefix(3)
        let string = topLines.map { $0.string + "..." }
//            .joined()
            .joined(separator: "\n")
        return string
    }
}
