//
//  PhotosVC+SlidesChanged.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func slidesChanged(findPhoto: FindPhoto) {
        print("Changed")
//        let findPhoto = allPhotosToDisplay[index]
        for month in allMonths {
            for photo in month.photos {
                if photo.asset.localIdentifier == findPhoto.asset.localIdentifier {
                    photo.editableModel = findPhoto.editableModel
                    
                    print("photo cache : \(photo.editableModel?.isDeepSearched)")
                    print("photo heart : \(photo.editableModel?.isHearted)")
                    print("Found!")
                    break
                }
            }
        }
        
        sortPhotos(with: currentFilter)
        applySnapshot(animatingDifferences: true)
        
        
//        if let indexPath = dataSource.indexPath(for: findPhoto) {
//            print("has index")
//            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
//                if let model = findPhoto.editableModel {
//                    if model.isDeepSearched {
//                        cell.cacheImageView.image = UIImage(named: "CacheActive-Light")
//                    } else {
//                        cell.cacheImageView.image = nil
//                    }
//                    if model.isHearted {
//                        cell.starImageView.image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
//                    } else {
//                        cell.starImageView.image = nil
//                    }
//                    if model.isDeepSearched || model.isHearted {
//                        cell.shadowImageView.image = UIImage(named: "DownShadow")
//                    } else {
//                        cell.shadowImageView.image = nil
//                    }
//                } else {
//                    cell.cacheImageView.image = nil
//                    cell.starImageView.image = nil
//                    cell.shadowImageView.image = nil
//                }
////                sortPhotos(with: currentFilter)
////                applySnapshot(animatingDifferences: true)
//            }
//        }
    }
}
