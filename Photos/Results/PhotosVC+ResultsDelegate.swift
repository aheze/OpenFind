//
//  PhotosVC+ResultsDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func willDisplayCell(cell: PhotosResultsCell, index: Int) {
        guard let findPhoto = model.resultsState?.findPhotos[safe: index] else { return }

        cell.highlightsViewController?.view.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier else { return }
            let highlights = self.getHighlights(for: cell, with: findPhoto)
            print("Gettomg highlights: \(highlights.count)")
            if let highlightsViewController = cell.highlightsViewController {
                highlightsViewController.highlightsViewModel.highlights = highlights
            } else {
                let highlightsViewModel = HighlightsViewModel()
                highlightsViewModel.highlights = highlights
                let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
                self.addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
                cell.highlightsViewController = highlightsViewController
            }

            UIView.animate(withDuration: 0.1) {
                cell.highlightsViewController?.view.alpha = 1
            }
        }
    }
}
