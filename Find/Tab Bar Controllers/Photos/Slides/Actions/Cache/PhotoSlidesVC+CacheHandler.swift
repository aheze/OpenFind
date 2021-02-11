//
//  PhotoSlidesVC+CacheHandler.swift
//  Find
//
//  Created by Zheng on 2/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func startCaching() {
        temporaryCachingPhoto?.cachePressed = true
        updateActions?(.currentlyCaching)
        
        let currentPhoto = resultPhotos[currentIndex].findPhoto
        
        if let cachingPhoto = temporaryCachingPhoto {
            if !cachingPhoto.contents.isEmpty { /// finished already
                updateActions?(.shouldNotCache)
                findAfterCached()
            } else {
                updateActions?(.currentlyCaching)
                messageView.unHideMessages()
            }
            
        } else {
            pageViewController.dataSource = nil
            temporaryCachingPhoto = TemporaryCachingPhoto()
            temporaryCachingPhoto?.cachePressed = true
            
            CachingFinder.getRealRealmModel = { [weak self] object in
                guard let self = self else { return nil }
                if let realObject = self.getRealModel?(object) {
                    return realObject
                } else {
                    return nil
                }
            }
            CachingFinder.finishedFind = { [weak self] in
                guard let self = self else { return }
                self.finishedCaching()
            }
            CachingFinder.reportProgress = { [weak self] progress in
                guard let self = self else { return }
                print("prpg: \(progress), curr: \(self.currentProgress)")
                
                if let cachingPhoto = self.temporaryCachingPhoto, cachingPhoto.cachePressed {
                    if progress > self.currentProgress {
                        let percent = progress * 100
                        let roundedPercent = Int(percent.rounded())
                        self.messageView.updateMessage("\(roundedPercent)")
                    }
                }
                
                self.currentProgress = CGFloat(progress)
            }
            CachingFinder.load(with: [currentPhoto])
            CachingFinder.startFinding()
            
            
            messageView.showMessage("0", dismissible: false, duration: -1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let cachingPhoto = self.temporaryCachingPhoto, cachingPhoto.cachePressed {
                    self.messageView.showMessage("25", dismissible: false, duration: -1)
                }
            }
        }
    }
    func finishedCaching() {
        DispatchQueue.main.async {
            
            
            if let firstFindPhoto = CachingFinder.alreadyCachedPhotos.first, let tempPhoto = self.temporaryCachingPhoto {
                if let contents = firstFindPhoto.editableModel?.contents {
                    tempPhoto.contents = contents
                }
                
                if tempPhoto.cachePressed {
                    print("cach press")
                    self.pageViewController.dataSource = self
                    self.messageView.updateMessage("100")
                    self.messageView.hideMessages()
                    self.updateActions?(.shouldNotCache)
                    
                    self.findPhotoChanged?(firstFindPhoto)
                    
                    if self.findPressed {
                        print("find pressed")
                        self.findAfterCached()
                    }
                    
                    let photoExists = self.checkIfPhotoExists?(firstFindPhoto)
                    if photoExists == false {
                        print("Cached photo does not exist")
                        self.removeCurrentSlide()
                    }
                }
            }
        }
    }
}
