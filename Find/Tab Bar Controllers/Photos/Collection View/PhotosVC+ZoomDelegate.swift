//
//  PhotosVC+Transition.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController: ZoomAnimatorDelegate {
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        if !zoomAnimator.isPresenting {
            dimSlideControls?(true, false)
        }
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        if zoomAnimator.isPresenting == false {
            if zoomAnimator.finishedDismissing == false {
                dimSlideControls?(false, false)
            } else {
                /// finished dismissing
                currentSlidesController = nil
                changePresentationMode(presentingSlides: false)
                hideTabBar?(false)
                
                if refreshNeededAfterDismissPhoto {
                    refreshNeededAfterDismissPhoto = false
                    refreshing = true
                    DispatchQueue.main.async {
                        self.loadImages { allPhotos, allMonths in
                            self.allMonths = allMonths
                            self.monthsToDisplay = allMonths
                            self.allPhotosToDisplay = allPhotos
                            self.sortPhotos(with: self.photoFilterState)
                            self.applySnapshot(animatingDifferences: true)
                            self.refreshing = false
                        }
                    }
                }
            }
        }
        
        guard let selectedIndexPath = selectedIndexPath else { return }
        
        if let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell {
            if zoomAnimator.isPresenting == false, zoomAnimator.finishedDismissing == true {
                if
                    let findPhoto = dataSource.itemIdentifier(for: selectedIndexPath),
                    let model = findPhoto.editableModel
                {
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.cacheImageView.alpha = model.isDeepSearched ? 1 : 0
                        cell.starImageView.alpha = model.isHearted ? 1 : 0
                        cell.shadowImageView.alpha = (model.isDeepSearched || model.isHearted) ? 1 : 0
                    })
                }
            }
            
            let cellFrame = collectionView.convert(cell.frame, to: view)
            
            if cellFrame.minY < collectionView.contentInset.top {
                collectionView.scrollToItem(at: selectedIndexPath, at: .top, animated: false)
            } else if cellFrame.maxY > view.frame.height - collectionView.contentInset.bottom {
                collectionView.scrollToItem(at: selectedIndexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        // Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        // Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath)
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
}
