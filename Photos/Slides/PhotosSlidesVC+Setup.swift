//
//  PhotosSlidesVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosSlidesViewController {
    func setup() {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        setupCollectionView()
        setupScrollView()
        setupInfo()
        setupNavigationBar()
        
        contentView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        collectionViewContainer.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        
        collectionViewContainer.accessibilityTraits = .none
        collectionViewContainer.isAccessibilityElement = true
        collectionViewContainer.model = model
        collectionViewContainer.increment = { [weak self] in
            guard let self = self else { return }
            
            if
                let slidesState = self.model.slidesState,
                let currentIndex = slidesState.getCurrentIndex()
            {
                if currentIndex < slidesState.slidesPhotos.count - 1 {
                    let nextIndex = currentIndex + 1
                    self.model.slidesState?.currentPhoto = slidesState.slidesPhotos[safe: nextIndex]?.findPhoto.photo
                    self.model.slidesCurrentPhotoChanged?()
                    self.collectionView.scrollToItem(at: nextIndex.indexPath, at: .centeredHorizontally, animated: true)
                    if
                        let cell = self.collectionView.cellForItem(at: nextIndex.indexPath) as? PhotosSlidesContentCell,
                        let viewController = cell.viewController
                    {
                        viewController.containerView.alpha = 1
                    }
                }
            }
        }
        collectionViewContainer.decrement = { [weak self] in
            guard let self = self else { return }
            
            if
                let slidesState = self.model.slidesState,
                let currentIndex = slidesState.getCurrentIndex()
            {
                if currentIndex > 0 {
                    let previousIndex = currentIndex - 1
                    self.model.slidesState?.currentPhoto = slidesState.slidesPhotos[safe: previousIndex]?.findPhoto.photo
                    self.model.slidesCurrentPhotoChanged?()
                    self.collectionView.scrollToItem(at: previousIndex.indexPath, at: .centeredHorizontally, animated: true)
                    if
                        let cell = self.collectionView.cellForItem(at: previousIndex.indexPath) as? PhotosSlidesContentCell,
                        let viewController = cell.viewController
                    {
                        viewController.containerView.alpha = 1
                    }
                }
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.keyboardDismissMode = .interactive
        collectionView.decelerationRate = .fast
        collectionView.collectionViewLayout = flowLayout
    }
}
