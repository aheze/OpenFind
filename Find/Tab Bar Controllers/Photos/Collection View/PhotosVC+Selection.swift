//
//  PhotosVC+Selection.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            if !indexPathsSelected.contains(indexPath) {
                indexPathsSelected.append(indexPath)
                numberOfSelected += 1
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
//                    UIView.animate(withDuration: 0.1, animations: {
//                        cell.highlightView.alpha = 1
//                        cell.checkmarkView.alpha = 1
//                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                    })
                }
            }
            
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            print("selected at \(indexPath)")
            presentFromIndexPath(indexPath: indexPath)
            
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath)
            numberOfSelected -= 1
            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            }
        }
    }
}

