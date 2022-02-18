//
//  PhotosVC+Transition.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController: PhotoTransitionAnimatorDelegate {
    func transitionWillStart() {}
    
    func transitionDidEnd() {}
    
    func referenceImage() -> UIImage? {
        if let currentIndex = self.model.slidesState?.currentIndex {
            let image = self.model.slidesState?.findPhotos[currentIndex].image
            return image
        }
        return nil
    }
    
    func imageFrame() -> CGRect? {
        guard
            let slidesState = model.slidesState,
            let currentIndex = slidesState.currentIndex,
            let photo = model.photos[safe: currentIndex],
            let photoIndexPath = model.getPhotoIndexPath(photo: photo)
        else {
            return nil
        }
        
        if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
            let frame = cell.imageView.windowFrame()
            return frame
        }
        return nil
    }
}
