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
            let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
            let clearThisCacheQuestion = NSLocalizedString("clearThisCacheQuestion", comment: "Multifile def=Clear this photo's cache?")
            let cachingAgainTakeAWhile = NSLocalizedString("cachingAgainTakeAWhile", comment: "Multifile def=Caching again will take a while...")
            let clear = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
            
            let alert = UIAlertController(title: clearThisCacheQuestion, message: cachingAgainTakeAWhile, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: clear, style: UIAlertAction.Style.destructive, handler: { _ in
                if realModel.isDeepSearched {
                    do {
                        try self.realm.write {
                            realModel.isDeepSearched = false
                            self.realm.delete(realModel.contents)
                        }
                    } catch {
                        print("Error starring photo \(error)")
                    }
                    editableModel.isDeepSearched = false /// also change the editable model
                    editableModel.contents.removeAll()

                    self.findPhotoChanged?(findPhoto)
                    
                    if
                        let photoExists = self.checkIfPhotoExists?(findPhoto),
                        photoExists == false
                    {
                        self.removeCurrentSlide()
                    } else {
                        self.updateActions?(.shouldCache) /// only change label if still exists
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect =  CGRect(x: (self.view.bounds.width / 2) - 40, y: self.view.bounds.height - 80, width: 80, height: 80)
            }
            self.present(alert, animated: true, completion: nil)
            
            
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
        
    }
}

extension PhotoSlidesViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [FindPhoto], returnResult: CacheReturn) {
        print("Given: \(photos)")
        
        if returnResult == .completedAll {
            updateActions?(.shouldNotCache)
            
            if let firstFindPhoto = photos.first {
                findPhotoChanged?(firstFindPhoto)
                
                if findPressed {
                    print("find pressed")
                    findAfterCached()
                }
                
                let photoExists = checkIfPhotoExists?(firstFindPhoto)
                if photoExists == false {
                    print("Cached photo does not exist")
                    removeCurrentSlide()
                }
            }
        }
    }
}

