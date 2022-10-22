//
//  PhotosSlidesVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

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
        
        setupVoiceOverToolbar()
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
        collectionView.alwaysBounceHorizontal = true /// allow bouncing even when only 1 photo
    }
}
