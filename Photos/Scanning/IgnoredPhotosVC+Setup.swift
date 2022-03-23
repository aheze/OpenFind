//
//  IgnoredPhotosVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController {
    func setup() {
        setupCollectionView()
        setupNavigationBar()
    }

    func setupCollectionView() {
        collectionView.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: "PhotosCollectionCell")

        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()

        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
    }

    func setupNavigationBar() {
        let selectButton = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(selectPressed)
        )

        navigationItem.rightBarButtonItem = selectButton
    }

    @objc func selectPressed() {
        
    }
}
