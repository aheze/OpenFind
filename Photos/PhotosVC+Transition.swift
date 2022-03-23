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
            
            if model.resultsState != nil {
                if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                    cell.imageView.alpha = 0
                }
            } else {
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                    cell.alpha = 0
                }
            }
        case .pop:
            
            /// update the highlight colors if necessary
            self.model.updateSearchCollectionView?()
            self.updateResultsHighlightColors()
            
            if let resultsState = model.resultsState {
                for index in resultsState.findPhotos.indices {
                    if let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell {
                        cell.imageView.alpha = 1
                    }
                }
                
                guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            
                let hideCell = { [weak self] in
                    if let cell = self?.resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                        cell.imageView.alpha = 0
                        cell.leftOverlayView.alpha = 0
                    }
                }
            
                if resultsCollectionView.indexPathsForVisibleItems.contains(photoIndexPath) {
                    hideCell()
                } else {
                    resultsCollectionView.scrollToItem(at: photoIndexPath, at: .centeredVertically, animated: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        hideCell()
                    }
                }
            } else {
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
                    guard let self = self else { return }
                    if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                        cell.alpha = 0
                        cell.view.overlayView.alpha = 0
                        
                        if let header = self.getCurrentHeader(for: photoIndexPath) {
                            header.alpha = 0
                        }
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
    }
    
    func transitionDidEnd(type: PhotoTransitionAnimatorType) {
        model.animatingSlides = false
        switch type {
        case .push:
            break
        case .pop:
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            if model.resultsState != nil {
                if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                    cell.imageView.alpha = 1
                    
                    UIView.animate(withDuration: 0.3) {
                        cell.leftOverlayView.alpha = 1
                    }
                }
            } else {
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                    cell.alpha = 1
                    
                    /// show the shadow overlay again (doesn't matter if actually starred or not, that is determined by the subviews)
                    UIView.animate(withDuration: 0.3) {
                        cell.view.overlayView.alpha = 1
                    }
                }
                if let header = getCurrentHeader(for: photoIndexPath) {
                    UIView.animate(withDuration: 0.3) {
                        header.alpha = 1
                    }
                }
            }
        }
    }
    
    func referenceImage(type: PhotoTransitionAnimatorType) -> UIImage? {
        if
            let currentIndex = model.slidesState?.getCurrentIndex(),
            let thumbnail = self.model.slidesState?.findPhotos[currentIndex].thumbnail
        {
            return thumbnail
        } else {
            if model.resultsState != nil {
                /// If no image is available yet, use what is shown in the collection view cell
                guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
                if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                    return cell.imageView.image
                }
            } else {
                /// If no image is available yet, use what is shown in the collection view cell
                guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                    return cell.view.imageView.image
                }
            }
        }
        
        return nil
    }
    
    func imageFrame(type: PhotoTransitionAnimatorType) -> CGRect? {
        guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
        if model.resultsState != nil {
            if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                let frame = cell.imageView.windowFrame()
                return frame
            }
        } else {
            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCollectionCell {
                let frame = cell.view.imageView.windowFrame()
                return frame
            }
        }
        return nil
    }
    
    /// get the index path from the photo presented in slides
    func getCurrentPhotoIndexPath() -> IndexPath? {
        /// get index within the results collection view
        if model.resultsState != nil {
            guard
                let slidesState = model.slidesState,
                let photo = slidesState.currentPhoto,
                let resultsIndex = model.resultsState?.getFindPhotoIndex(photo: photo)
            else { return nil }
            return resultsIndex.indexPath
        } else {
            /// get index within the main collection view
            guard
                let slidesState = model.slidesState,
                let photo = slidesState.currentPhoto,
                let index = model.getPhotoIndexPath(photo: photo)
            else { return nil }
            return index
        }
    }
    
    func imageCornerRadius(type: PhotoTransitionAnimatorType) -> CGFloat {
        if model.resultsState != nil {
            return PhotosResultsCellConstants.leftContainerCornerRadius
        }
        return 0
    }
    
    /// get the header that is at the top of the current photo's section
    func getCurrentHeader(for photoIndexPath: IndexPath) -> PhotosCollectionHeader? {
        if
            case .sections(let sectionLayouts) = flowLayout.photosAttributes,
            let section = model.sections[safe: photoIndexPath.section],
            let headerIndex = sectionLayouts.firstIndex(where: {
                $0.headerLayoutAttributes.encompassingCategorizations.contains(section.categorization) &&
                $0.headerLayoutAttributes.isVisible
            }),
            let header = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: headerIndex)
            ) as? PhotosCollectionHeader
        {
            return header
        }
        return nil
    }
}
