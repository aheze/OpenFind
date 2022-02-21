//
//  PhotosVC+Transition.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController: PhotoTransitionAnimatorDelegate {
    func transitionWillStart(type: PhotoTransitionAnimatorType) {
        /// make sure to set this inside the `presentSlides` function too
        /// since this could be called too late (in the case that the first photo was pressed)
        model.animatingSlides = true
        
        switch type {
        case .push:
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                cell.alpha = 0
            }
        case .pop:
            for sectionIndex in model.sections.indices {
                for photoIndex in model.sections[sectionIndex].photos.indices {
                    let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                    if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionCell {
                        cell.alpha = 1
                    }
                }
            }
            
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            
            let hideCell = { [weak self] in
                if let cell = self?.collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                    cell.alpha = 0
                }
            }
            
            if collectionView.indexPathsForVisibleItems.contains(photoIndexPath) {
                hideCell()
            } else {
                collectionView.scrollToItem(at: photoIndexPath, at: .centeredVertically, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    hideCell()
                }
            }
        }
    }
    
    func transitionDidEnd(type: PhotoTransitionAnimatorType) {
        model.animatingSlides = false
        switch type {
        case .push:
            break
        case .pop:
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                cell.alpha = 1
            }
        }
    }
    
    func referenceImage(type: PhotoTransitionAnimatorType) -> UIImage? {
        if
            let currentIndex = model.slidesState?.currentIndex,
            let thumbnail = self.model.slidesState?.findPhotos[currentIndex].thumbnail
        {
            return thumbnail
        } else {
            /// If no image is available yet, use what is shown in the collection view cell
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                return cell.imageView.image
            }
        }
        return nil
    }
    
    func imageFrame(type: PhotoTransitionAnimatorType) -> CGRect? {
        guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
        if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
            let frame = cell.imageView.windowFrame()
            return frame
        }
        return nil
    }
    
    func getCurrentPhotoIndexPath() -> IndexPath? {
        guard
            let slidesState = model.slidesState,
            let currentIndex = slidesState.currentIndex,
            let photo = model.photos[safe: currentIndex],
            let photoIndexPath = model.getPhotoIndexPath(photo: photo)
        else {
            return nil
        }
        return photoIndexPath
    }
}
