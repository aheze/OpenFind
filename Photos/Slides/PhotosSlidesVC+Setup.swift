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
    }
    
    func setupScrollView() {
        scrollView.contentInsetAdjustmentBehavior = .never
        
        /// don't use `scrollView.bounds.height`, it will be less
        collectionViewContainerHeightC.constant = view.bounds.height
        intoViewContainerHeightC.constant = 0
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
