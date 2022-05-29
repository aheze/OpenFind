//
//  PhotosVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/// Scroll view
extension PhotosViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBlur(with: scrollView)

        /// For photos caching
        updateCachedAssets()
    }

    /// update the blur with a scroll view's content offset
    func updateNavigationBlur(with scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotosCell {
            configureCell(cell: cell, indexPath: indexPath)
        }

        /// handle logic in `PhotosVC+ResultsDataSource`
        if let cell = cell as? PhotosCellResults {
            configureCellResults(cell: cell, indexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotosCell {
            teardownCell(cell: cell, indexPath: indexPath)
        }

        if let cell = cell as? PhotosCellResults {
            teardownCellResults(cell: cell, indexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        if model.isSelecting {
            return true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.isSelecting {
            if model.resultsState != nil {
                photoResultsSelected(at: indexPath)
            } else {
                photoSelected(at: indexPath)
            }
        } else {
            if let resultsState = model.resultsState {
                if let findPhoto = resultsState.displayedFindPhotos[safe: indexPath.item] {
                    presentSlides(startingAtFindPhoto: findPhoto)
                }
            } else {
                if let photo = model.displayedSections[safe: indexPath.section]?.photos[safe: indexPath.item] {
                    presentSlides(startingAtPhoto: photo)
                }
            }

            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if model.isSelecting {
            if model.resultsState != nil {
                photoResultsDeselected(at: indexPath)
            } else {
                photoDeselected(at: indexPath)
            }
        }
    }

    /// **for results only**
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if model.resultsState != nil {
            if let cell = resultsCollectionView.cellForItem(at: indexPath) as? PhotosResultsCell {
                UIView.animate(withDuration: 0.2) {
                    cell.baseView.alpha = 0.75
                    cell.transform = .init(scaleX: 0.97, y: 0.97)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if model.resultsState != nil {
            if let cell = resultsCollectionView.cellForItem(at: indexPath) as? PhotosResultsCell {
                UIView.animate(withDuration: 0.2) {
                    cell.baseView.alpha = 1
                    cell.transform = .identity
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard model.resultsState == nil else { return nil }
        guard let photo = model.displayedSections[safe: indexPath.section]?.photos[safe: indexPath.item] else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] action in
                self?.model.share(photos: [photo])
            }

            let star: UIAction
            if photo.isStarred {
                star = UIAction(title: "Unstar", image: UIImage(systemName: "star")) { [weak self] action in
                    self?.model.star(photos: [photo])
                    self?.model.updateAfterStarChange()
                }
            } else {
                star = UIAction(title: "Star", image: UIImage(systemName: "star.fill")) { [weak self] action in
                    self?.model.star(photos: [photo])
                    self?.model.updateAfterStarChange()
                }
            }

            let ignore: UIAction
            if photo.isIgnored {
                ignore = UIAction(title: "Unignore", image: UIImage(systemName: "nosign")) { [weak self] action in
                    self?.model.ignore(photos: [photo])
                }
            } else {
                ignore = UIAction(title: "Ignore", image: UIImage(systemName: "nosign")) { [weak self] action in
                    self?.model.ignore(photos: [photo])
                }
            }

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
                self?.model.delete(photos: [photo])
            }

            // Create other actions...

            return UIMenu(title: "", children: [share, star, ignore, delete])
        }
    }
}
