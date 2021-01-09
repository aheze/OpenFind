//
//  PhotosVC+Transition.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

/// When the slides pages left or right
extension PhotosViewController: PhotoSlidesUpdatedIndex {
    
    func indexUpdated(to newIndex: Int) {
        let currentPhoto = allPhotosToDisplay[newIndex]
        if let indexPath = dataSource.indexPath(for: currentPhoto) {
            if let selectedIndexPath = selectedIndexPath {
                if let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell {
                    if let model = currentPhoto.model {
                        if model.isHearted || model.isDeepSearched  {
                            cell.shadowImageView.alpha = 1
                        } else {
                            cell.shadowImageView.alpha = 0
                        }
                        if model.isHearted {
                            cell.starImageView.alpha = 1
                        } else {
                            cell.starImageView.alpha = 0
                        }
                        if model.isDeepSearched {
                            cell.cacheImageView.alpha = 1
                        } else {
                            cell.cacheImageView.alpha = 0
                        }
                    }
                }
            }
            
            selectedIndexPath = indexPath
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        }
    }
}

extension PhotosViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        guard let selectedIndexPath = selectedIndexPath else { return }
        let cell = collectionView.cellForItem(at: selectedIndexPath) as! ImageCell
        
        let cellFrame = collectionView.convert(cell.frame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            collectionView.scrollToItem(at: selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > view.frame.height - collectionView.contentInset.bottom {
            collectionView.scrollToItem(at: selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath)
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}



//extension PhotosViewController: ZoomAnimatorDelegate {
//
//    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
//        print("starting")
//    }
//
//    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
//        print("ended")
//        guard let selectedIndexPath = selectedIndexPath else {
//            print("no index path")
//            return
//        }
//        if zoomAnimator.isPresenting == false && zoomAnimator.finishedDismissing == true {
//
//
//            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell {
//                if
//                    let findPhoto = dataSource.itemIdentifier(for: selectedIndexPath),
//                    let model = findPhoto.model
//                {
//                    UIView.animate(withDuration: 0.2, animations: {
//                        if model.isHearted || model.isDeepSearched  {
//                            cell.shadowImageView.alpha = 1
//                        }
//                        if model.isHearted {
//                            cell.starImageView.alpha = 1
//                        }
//                        if model.isDeepSearched {
//                            cell.cacheImageView.alpha = 1
//                        }
//                    })
//                }
//            }
//        }
//        if let cell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell {
//            let cellFrame = collectionView.convert(cell.frame, to: view)
//
//            if cellFrame.minY < collectionView.contentInset.top {
//                collectionView.scrollToItem(at: selectedIndexPath, at: .top, animated: false)
//            } else if cellFrame.maxY > view.frame.height - collectionView.contentInset.bottom {
//                collectionView.scrollToItem(at: selectedIndexPath, at: .bottom, animated: false)
//            }
//        }
//    }
//
//    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
//        print("get reference")
//        guard let selectedIndexPath = selectedIndexPath else {
//            print("no index path")
//            return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
//        }
//        //Get a guarded reference to the cell's UIImageView
//        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
//
//        return referenceImageView
//    }
//
//    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
//        print("get image view frame")
//        guard let selectedIndexPath = selectedIndexPath else {
//            print("no index path")
//            return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
//        }
//
//        view.layoutIfNeeded()
//        collectionView.layoutIfNeeded()
//
//        //Get a guarded reference to the cell's frame
//        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath)
//
//        var cellFrame = collectionView.convert(unconvertedFrame, to: view)
//
//        if cellFrame.minY < collectionView.contentInset.top {
//            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
//        }
//
//        let superCellFrame = collectionView.convert(unconvertedFrame, to: nil)
//        let cellYDiff = superCellFrame.origin.y - cellFrame.origin.y
//        let cellXDiff = superCellFrame.origin.x - cellFrame.origin.x
//
//        cellFrame.origin.y += cellYDiff
//        cellFrame.origin.x += cellXDiff
//        ///works on ipad now
//        ///need to fix this, no hardcoded values
//        return cellFrame
//    }
//    //This function prevents the collectionView from accessing a deallocated cell. In the event
//    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
//    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
//        print("get image")
//        //Get the array of visible cells in the collectionView
//        let visibleCells = collectionView.indexPathsForVisibleItems
//
//        print("sele: \(selectedIndexPath), visible")
//
//        //If the current indexPath is not visible in the collectionView,
//        //scroll the collectionView to the cell to prevent it from returning a nil value
//        if !visibleCells.contains(selectedIndexPath) {
//
//            //Scroll the collectionView to the current selectedIndexPath which is offscreen
//            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
//
//            //Reload the items at the newly visible indexPaths
//            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
//            collectionView.layoutIfNeeded()
//
//            //Guard against nil values
//            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
//                //Return a default UIImageView
//                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
//            }
//
//            print("returning")
//            //The PhotoCollectionViewCell was found in the collectionView, return the image
//            return guardedCell.imageView
//        }
//        else {
//
//            //Guard against nil return values
//            guard let guardedCell = collectionView.cellForItem(at: selectedIndexPath) as? ImageCell else {
//                //Return a default UIImageView
//                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
//            }
//            //The PhotoCollectionViewCell was found in the collectionView, return the image
//
//            print("rturning 2")
//            return guardedCell.imageView
//        }
//
//    }
//
//    //This function prevents the collectionView from accessing a deallocated cell. In the
//    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
//    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
//
//        //Get the currently visible cells from the collectionView
//        let visibleCells = collectionView.indexPathsForVisibleItems
//
//        //If the current indexPath is not visible in the collectionView,
//        //scroll the collectionView to the cell to prevent it from returning a nil value
//        if !visibleCells.contains(selectedIndexPath) {
//
//            //Scroll the collectionView to the cell that is currently offscreen
//            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
//
//            //Reload the items at the newly visible indexPaths
//            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
//            collectionView.layoutIfNeeded()
//
//            //Prevent the collectionView from returning a nil value
//            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
//                return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
//            }
//
//            return guardedCell.frame
//        }
//            //Otherwise the cell should be visible
//        else {
//            //Prevent the collectionView from returning a nil value
//            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? ImageCell) else {
//                return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
//            }
//            //The cell was found successfully
//            return guardedCell.frame
//        }
//    }
//}
