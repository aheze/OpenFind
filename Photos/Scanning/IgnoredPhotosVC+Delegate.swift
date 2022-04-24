//
//  IgnoredPhotosVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension IgnoredPhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        if model.ignoredPhotosIsSelecting {
            return true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.ignoredPhotosIsSelecting {
            photoSelected(at: indexPath)
        } else {
            if let photo = self.model.ignoredPhotos[safe: indexPath.item] {
                if let viewController = self.model.getSlidesViewControllerFor?(photo) {
                    viewController.navigationItem.scrollEdgeAppearance = UINavigationBarAppearance()
                    viewController.view.backgroundColor = .systemBackground
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }

            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if model.ignoredPhotosIsSelecting {
            photoDeselected(at: indexPath)
        }
    }
}
