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
                self.model.updateAllowed = false
                if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                    cell.view.imageView.alpha = 0
                }
            } else {
                if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCell {
                    cell.viewController?.model.showImage(false)
                }
            }
        case .pop:
            
            /// update the highlight colors if necessary
            self.model.updateSearchCollectionView?()
            self.updateResultsHighlightColors()
            
            if let resultsState = model.resultsState {
                for index in resultsState.displayedFindPhotos.indices {
                    if let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell {
                        cell.view.imageView.alpha = 1
                    }
                }
                
                guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            
                let hideCell = { [weak self] in
                    if let cell = self?.resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                        cell.view.imageView.alpha = 0
                        cell.view.overlayView.alpha = 0
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
                for sectionIndex in model.displayedSections.indices {
                    for photoIndex in model.displayedSections[sectionIndex].photos.indices {
                        let indexPath = IndexPath(item: photoIndex, section: sectionIndex)
                        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell {
                            cell.viewController?.model.showImage(true)
                        }
                    }
                }
            
                guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            
                let hideCell = { [weak self] in
                    guard let self = self else { return }
                    if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotosCell {
                        cell.viewController?.model.showImage(false)
                        cell.viewController?.model.showOverlay(false, animate: false)
                        
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
    
    func transitionDidEnd(type: PhotoTransitionAnimatorType, completed: Bool) {
        model.animatingSlides = false
        switch type {
        case .push:
            break
        case .pop:
            guard let photoIndexPath = getCurrentPhotoIndexPath() else { return }
            
            /// make sure completed first
            if completed {
                if model.resultsState != nil {
                    if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                        cell.view.imageView.alpha = 1
                    
                        UIView.animate(withDuration: 0.3) {
                            cell.view.overlayView.alpha = 1
                        }
                    }
                } else {
                    if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCell {
                        cell.viewController?.model.showImage(true)
                        
                        /// show the shadow overlay again (doesn't matter if actually starred or not, that is determined by the subviews)
                        cell.viewController?.model.showOverlay(true, animate: true)
                        
                    }
                    if let header = getCurrentHeader(for: photoIndexPath) {
                        UIView.animate(withDuration: 0.3) {
                            header.alpha = 1
                        }
                    }
                }

                /// remove slides state to keep finding in `PhotosVM+Update`
                self.model.slidesState = nil
                self.model.updateAllowed = true
            }
        }
    }
    
    func referenceImage(type: PhotoTransitionAnimatorType) -> UIImage? {
        guard let currentPhoto = model.slidesState?.currentPhoto else { return nil }
        if let resultsState = model.resultsState {
            if
                let index = resultsState.getFindPhotoIndex(for: currentPhoto, in: \.displayedFindPhotos),
                let cell = resultsCollectionView.cellForItem(at: index.indexPath) as? PhotosResultsCell
            {
                return cell.view.imageView.image
            }
        } else {
            if
                let indexPath = model.getIndexPath(for: currentPhoto, in: \.displayedSections),
                let cell = collectionView.cellForItem(at: indexPath) as? PhotosCell
            {
                return cell.viewController?.model.image
            }
        }
        
        return nil
    }
    
    func imageFrame(type: PhotoTransitionAnimatorType) -> CGRect? {
        guard let photoIndexPath = getCurrentPhotoIndexPath() else { return nil }
        if model.resultsState != nil {
            if let cell = resultsCollectionView.cellForItem(at: photoIndexPath) as? PhotosResultsCell {
                let frame = cell.view.imageView.windowFrame()
                return frame
            }
        } else {
            if let cell = collectionView.cellForItem(at: photoIndexPath) as? PhotosCell {
                let frame = cell.contentView.windowFrame()
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
                let resultsIndex = model.resultsState?.getFindPhotoIndex(for: photo, in: \.displayedFindPhotos)
            else { return nil }
            return resultsIndex.indexPath
        } else {
            /// get index within the main collection view
            guard
                let slidesState = model.slidesState,
                let photo = slidesState.currentPhoto,
                let indexPath = model.getIndexPath(for: photo, in: \.displayedSections)
            else { return nil }
            return indexPath
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
            let section = model.displayedSections[safe: photoIndexPath.section],
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
