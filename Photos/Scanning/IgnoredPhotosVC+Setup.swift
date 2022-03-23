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
        if #available(iOS 14.0, *) {
            let addAction = UIAction(
                title: "Add Photos",
                image: UIImage(systemName: "plus")
            ) { _ in
            }

            let editAction = UIAction(
                title: "Edit Photos",
                image: UIImage(systemName: "pencil")
            ) { _ in
            }

            let optionsButton = UIBarButtonItem(
                title: "",
                image: UIImage(systemName: "ellipsis"),
                menu: UIMenu(title: "", children: [
                    addAction,
                    editAction
                ])
            )

            navigationItem.rightBarButtonItem = optionsButton
        }
    }
}
