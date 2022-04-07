//
//  PhotosVC+ResultsDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func loadHighlights(for cell: PhotosResultsCell, findPhoto: FindPhoto) {
        cell.highlightsViewController?.view.alpha = 0

        guard cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier else {
            print("wrong represe")
            return
        }
        let highlights = self.getHighlights(for: cell, with: findPhoto)

        if let highlightsViewController = cell.highlightsViewController {
            removeChildViewController(highlightsViewController)
        }

        let highlightsViewModel = HighlightsViewModel()
        highlightsViewModel.highlights = highlights
        highlightsViewModel.shouldScaleHighlights = false /// highlights are already scaled
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
            cell.highlightsViewController = highlightsViewController

            UIView.animate(withDuration: 0.1) {
                cell.highlightsViewController?.view.alpha = 1
            }
        }
    }
}
