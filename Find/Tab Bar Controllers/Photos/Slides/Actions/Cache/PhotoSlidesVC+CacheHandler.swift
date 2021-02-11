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

                CachingFinder.saveToDisk(photo: currentPhoto, contentsToSave: cachingPhoto.contents)
                
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
            
            let newUUID = UUID()
            currentCachingIdentifier = newUUID /// set the current identifier
            CachingFinder.currentCachingIdentifier = newUUID
            
            CachingFinder.getRealRealmModel = { [weak self] object in
                guard let self = self else { return nil }
                if let realObject = self.getRealModel?(object) {
                    return realObject
                } else {
                    return nil
                }
            }
            CachingFinder.finishedFind = { [weak self] cachingIdentifier in
                guard let self = self else { return }
                
                if let currentCachingID = self.currentCachingIdentifier {
                    if cachingIdentifier == currentCachingID {
                        self.finishedCaching()
                    }
                }
                
            }
            CachingFinder.reportProgress = { [weak self] progress in
                guard let self = self else { return }
                
                if let cachingPhoto = self.temporaryCachingPhoto, cachingPhoto.cachePressed {
                    if progress > self.currentProgress {
                        let percent = progress * 100
                        let roundedPercent = Int(percent.rounded())
                        self.messageView.updateMessage("\(roundedPercent)")
                    }
                }
                
                self.currentProgress = CGFloat(progress)
            }
            
            var customFindArray = [String]()
            for key in matchToColors.keys {
                customFindArray.append(key)
                customFindArray.append(key.lowercased())
                customFindArray.append(key.uppercased())
                customFindArray.append(key.capitalizingFirstLetter())
            }
            CachingFinder.load(with: [currentPhoto], customWords: customFindArray)
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
            let currentPhoto = self.resultPhotos[self.currentIndex].findPhoto
            
            if let tempPhoto = self.temporaryCachingPhoto {
                
                if let unsavedContents = CachingFinder.unsavedContents {
                    tempPhoto.contents = unsavedContents
                    
                    if tempPhoto.cachePressed {
                        
                        CachingFinder.saveToDisk(photo: currentPhoto, contentsToSave: unsavedContents)
                        
                        self.pageViewController.dataSource = self
                        self.messageView.updateMessage("100")
                        self.messageView.hideMessages()
                        self.updateActions?(.shouldNotCache)
                        
                        self.findPhotoChanged?(currentPhoto)
                        
                        if self.findPressed {
                            self.findAfterCached()
                        }
                        
                        let photoExists = self.checkIfPhotoExists?(currentPhoto)
                        if photoExists == false {
                            self.removeCurrentSlide()
                        }
                    }
                    
                }
            }
        }
    }
}
