//
//  PhotoSlidesVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension PhotoSlidesViewController {
    func cachePhoto() {
        let findPhoto = resultPhotos[currentIndex].findPhoto
        
        if
            let editableModel = findPhoto.editableModel,
            let realModel = getRealModel?(editableModel),
            realModel.isDeepSearched
        {
            print("uncache")
        } else {
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
            
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            
            let cacheControllerHeight = max(screenBounds.size.height - CGFloat(300), 410)
            
            attributes.positionConstraints.size.height = .constant(value: cacheControllerHeight)
            attributes.positionConstraints.maxSize = .init(width: .constant(value: 450), height: .constant(value: 550))
            
            attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
            attributes.lifecycleEvents.didAppear = {
                cacheController.doneAnimating()
            }
            
            cacheController.photosToCache = [findPhoto]
            cacheController.getRealRealmModel = { [weak self] object in
                guard let self = self else { return nil }
                if let realObject = self.getRealModel?(object) {
                    return realObject
                } else {
                    return nil
                }
            }
            cacheController.finishedCache = self
            cacheController.view.layer.cornerRadius = 10
            
            SwiftEntryKit.display(entry: cacheController, using: attributes)
            
        }
        
        
        //            let assetIdentifier = findPhoto.asset.localIdentifier
        //            let newModel = HistoryModel()
        //            newModel.assetIdentifier = assetIdentifier
        //            newModel.isHearted = true
        //            newModel.isTakenLocally = false
        //
        //            do {
        //                try realm.write {
        //                    realm.add(newModel)
        //                }
        //            } catch {
//                print("Error saving model \(error)")
//            }
//            updateActions?(.shouldStar)
//            findPhotoChanged?(currentIndex)
//
//            let editableModel = EditableHistoryModel()
//            editableModel.assetIdentifier = assetIdentifier
//            editableModel.isHearted = true
//            editableModel.isTakenLocally = false
//
//            findPhoto.editableModel = editableModel
        
        
        
    }
}

extension PhotoSlidesViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [FindPhoto], returnResult: CacheReturn) {
        print("Given: \(photos)")
        
        if returnResult == .completedAll {
            updateActions?(.shouldNotStar)
            findPhotoChanged?(currentIndex)
            
            if
                let firstFindPhoto = photos.first,
                let photoExists = checkIfPhotoExists?(firstFindPhoto),
                photoExists == false {
                removeCurrentSlide()
                
            }
        }
    }
}

