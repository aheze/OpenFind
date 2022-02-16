//
//  PhotosSlidesVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photo = model.slidesState?.photos[safe: indexPath.item] {
            if let viewController = photo.associatedViewController {
                addChildViewController(viewController, in: cell.contentView)
            } else {
                
                let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
                let viewController = storyboard.instantiateViewController(identifier: "PhotosSlidesItemViewController") { coder in
                    PhotosSlidesItemViewController(
                        coder: coder,
                        model: self.model
                    )
                }
                
                addChildViewController(viewController, in: cell.contentView)
                model.slidesState?.photos[indexPath.item].associatedViewController = viewController
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let photo = model.slidesState?.photos[safe: indexPath.item] {
            if let viewController = photo.associatedViewController {
                removeChild(viewController)
                model.slidesState?.photos[indexPath.item].associatedViewController = nil
            }
        }
    }
}
