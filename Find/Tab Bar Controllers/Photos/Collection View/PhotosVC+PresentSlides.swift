//
//  PhotosVC+PresentSlides.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func presentFromIndexPath(indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowSlides", sender: self)
    }
      
    func configureSlides(navigationController: UINavigationController, slidesViewController: PhotoSlidesViewController) {

        
        
       
        
        
        
        if let indexPath = selectedIndexPath, let findPhoto = dataSource.itemIdentifier(for: indexPath) {
            
            
            navigationController.delegate = slidesViewController.transitionController
            slidesViewController.transitionController.fromDelegate = self
            slidesViewController.transitionController.toDelegate = slidesViewController
            slidesViewController.updatedIndex = self
            
            slidesViewController.findPhotos = allPhotosToDisplay
            
            
            if let currentIndex = allPhotosToDisplay.firstIndex(of: findPhoto) {
                slidesViewController.currentIndex = currentIndex
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
                slidesViewController.firstPlaceholderImage = cell.imageView.image
            }
            
            
            print("has findPhto")
//            if let currentIndex = allPhotosToDisplay.firstIndex(of: findPhoto) {
//                print("first")
//
//                let slidesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
//                                                                                                        "PhotoSlidesViewController") as! PhotoSlidesViewController
////                mainContentVC.title = "PhotoPageContainerViewController"
////                self.selectedIndexPath = indexPath
//                slidesViewController.transitioningDelegate = slidesViewController.transitionController
//                slidesViewController.transitionController.fromDelegate = self
//                slidesViewController.transitionController.toDelegate = slidesViewController
//                slidesViewController.updatedIndex = self
//                slidesViewController.currentIndex = currentIndex
//
////                slidesViewController.currentIndex
//
//                slidesViewController.findPhotos = allPhotosToDisplay
//
//
////                if let currentImage
////                mainContentVC.photoSize = imageSize
////                mainContentVC.cameFromFind = false
////                mainContentVC.folderURL = folderURL
//
////                mainContentVC.goDirectlyToFind = directFind
//
////                mainContentVC.highlightColor = highlightColor
////
////                mainContentVC.deletedPhoto = self
////                mainContentVC.changeModel = self
////                mainContentVC.changeCache = self
//
////                self.present(slidesViewController, animated: true)
////                self.navigationController?.pushViewController(slidesViewController, animated: true)
////                self.performSegue(withIdentifier: "ShowSlides", sender: self)
//            }
        }
        
        
        
        
//        if let currentIndex = indexPathToIndex[indexPath] {
//            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
//                guard let hisModel = self.indexToData[indexPath.section] else { print("NO CELL MODEL"); return }
//                let historyModel = hisModel[indexPath.item]
//                if historyModel.isHearted == true {
//                    UIView.animate(withDuration: 0.2, animations: {
//                        cell.heartView.alpha = 0
//                        cell.pinkTintView.alpha = 0
//                    })
//                }
//            }
//            
//            let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
//                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
//            mainContentVC.title = "PhotoPageContainerViewController"
//            self.selectedIndexPath = indexPath
//            mainContentVC.transitioningDelegate = mainContentVC.transitionController
//            mainContentVC.transitionController.fromDelegate = self
//            mainContentVC.transitionController.toDelegate = mainContentVC
//            mainContentVC.delegate = self
//            mainContentVC.currentIndex = currentIndex
//            mainContentVC.photoSize = imageSize
//            mainContentVC.cameFromFind = false
//            mainContentVC.folderURL = folderURL
//            
//            mainContentVC.goDirectlyToFind = directFind
//            
//            mainContentVC.highlightColor = highlightColor
//            
//            mainContentVC.deletedPhoto = self
//            mainContentVC.changeModel = self
//            mainContentVC.changeCache = self
//            
//            if let photoCats = photoCategories {
//                var modelArray = [EditableHistoryModel]()
//                for photo in photoCats {
//                    let newHistModel = EditableHistoryModel()
//                    newHistModel.filePath = photo.filePath
//                    newHistModel.dateCreated = photo.dateCreated
//                    newHistModel.isHearted = photo.isHearted
//                    newHistModel.isDeepSearched = photo.isDeepSearched
//                    
//                    for cont in photo.contents {
//                        let realmContent = EditableSingleHistoryContent()
//                        realmContent.text = cont.text
//                        realmContent.height = CGFloat(cont.height)
//                        realmContent.width = CGFloat(cont.width)
//                        realmContent.x = CGFloat(cont.x)
//                        realmContent.y = CGFloat(cont.y)
//                        newHistModel.contents.append(realmContent)
//                    }
//                    modelArray.append(newHistModel)
//                }
//                mainContentVC.photoModels = modelArray
//            }
//            self.present(mainContentVC, animated: true)
//        }
    }
}
