//
//  PhotosVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/13/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension PhotosViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [FindPhoto], returnResult: CacheReturn) {
        print("Given: \(photos)")
        
        applyModelSnapshot(changedItems: photos)
        sortPhotos(with: currentFilter)
        applySnapshot()
        
    }
    
//    func giveCachedPhotos(photos: [EditableHistoryModel], popup: String) {
//        <#code#>
//    }
}

extension PhotosViewController {
    func cache(_ shouldCache: Bool) {
        print("Should cache: \(shouldCache)")
        
        
        
        
        if shouldCache == true {
            
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
            
            
            var selectedPhotos = [FindPhoto]()
            for indexPath in indexPathsSelected {
                print("pho")
//                let itemToEdit = indexToData[item.section]
                if let item = dataSource.itemIdentifier(for: indexPath) {
                    selectedPhotos.append(item)
                    print("appenidng")
                    print("Has model? \(item.model)")
                }
            }
            
//            cacheController.folderURL = folderURL
            cacheController.photosToCache = selectedPhotos
            cacheController.finishedCache = self
            cacheController.view.layer.cornerRadius = 10
            
            selectButtonSelected = false
//            fadeSelectOptions(fadeOut: "fade out")
            SwiftEntryKit.dismiss()
            collectionView.allowsMultipleSelection = false
            
            SwiftEntryKit.display(entry: cacheController, using: attributes)
        }
//        else {
//            var arrayOfUncache = [Int]()
//            for indexP in indexPathsSelected {
//                if let index = indexPathToIndex[indexP] {
//                    arrayOfUncache.append(index)
//                }
//            }
//            //
//            //                var titleMessage = ""
//            //                var finishMessage = ""
//            //                if arrayOfUncache.count == 1 {
//            //                    titleMessage = "Clear this photo's cache?"
//            //                    finishMessage = "Cache cleared!"
//            //                } else if arrayOfUncache.count == photoCategories?.count {
//            //                    titleMessage = "Clear ENTIRE cache?!"
//            //                    finishMessage = "Entire cache cleared!"
//            //                } else {
//            //                    titleMessage = "Clear \(arrayOfUncache.count) photos' caches?"
//            //                    finishMessage = "\(arrayOfUncache.count) caches deleted!"
//            //                }
//            //
//
//            var titleMessage = ""
//            var finishMessage = ""
//            if indexPathsSelected.count == 1 {
//
//                let clearThisCacheQuestion = NSLocalizedString("clearThisCacheQuestion", comment: "Multifile def=Clear this photo's cache?")
//                let cacheClearedExclaim = NSLocalizedString("cacheClearedExclaim", comment: "NewHistoryViewController def=Cache cleared!")
//
//
//                titleMessage = clearThisCacheQuestion
//                finishMessage = cacheClearedExclaim
//            } else if indexPathsSelected.count == photoCategories?.count {
//                let deleteEntireCacheQuestion = NSLocalizedString("deleteEntireCacheQuestion", comment: "NewHistoryViewController def=Clear ENTIRE cache?!")
//                let entireCacheDeletedExclaim = NSLocalizedString("entireCacheDeletedExclaim", comment: "NewHistoryViewController def=Entire cache cleared!")
//
//                titleMessage = deleteEntireCacheQuestion
//                finishMessage = entireCacheDeletedExclaim
//            } else {
//                let deletexCaches = NSLocalizedString("Delete %d caches?", comment:"NewHistoryViewController def=Clear x photos' caches?")
//
//                let finishedDeletexCaches = NSLocalizedString("%d photos caches deleted!", comment:"NewHistoryViewController def=x caches cleared!")
//
//
//                titleMessage = String.localizedStringWithFormat(deletexCaches, arrayOfUncache.count)
//                finishMessage = String.localizedStringWithFormat(finishedDeletexCaches, arrayOfUncache.count)
//                //            titleMessage = "Delete \(indexPathsSelected.count) lists?"
//                //            finishMessage = "\(indexPathsSelected.count) lists deleted!"
//            }
//
//            let cachingAgainTakeAWhile = NSLocalizedString("cachingAgainTakeAWhile", comment: "Multifile def=Caching again will take a while...")
//            let clear = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
//
//            let alert = UIAlertController(title: titleMessage, message: cachingAgainTakeAWhile, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: clear, style: UIAlertAction.Style.destructive, handler: { _ in
//                self.uncachePhotos(at: arrayOfUncache)
//                let alertView = SPAlertView(title: finishMessage, message: self.tapToDismiss, preset: SPAlertPreset.done)
//                alertView.duration = 2.6
//                alertView.present()
//
//                self.selectButtonSelected = false
//                self.fadeSelectOptions(fadeOut: "fade out")
//                SwiftEntryKit.dismiss()
//                self.collectionView.allowsMultipleSelection = false
//            }))
//            alert.addAction(UIAlertAction(title: self.cancel, style: UIAlertAction.Style.cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
        
        
        
        
        
        
        
        
        
        
        
//        var changedPhotos = [FindPhoto]()
//        if shouldCache {
//            for indexPath in indexPathsSelected {
//                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
//                    if let model = findPhoto.model {
//                        if !model.isHearted { /// only star if not starred
//                            changedPhotos.append(findPhoto)
//                            do {
//                                try realm.write {
//                                    model.isHearted = true
//                                }
//                            } catch {
//                                print("Error starring photo \(error)")
//                            }
//                        }
//                    } else {
//                        changedPhotos.append(findPhoto)
//                        let assetIdentifier = findPhoto.asset.localIdentifier
//                        let newModel = HistoryModel()
//                        newModel.assetIdentifier = assetIdentifier
//                        newModel.isHearted = true
//                        newModel.isTakenLocally = false
//
//                        do {
//                            try realm.write {
//                                realm.add(newModel)
//                            }
//                        } catch {
//                            print("Error saving model \(error)")
//                        }
//
//                        findPhoto.model = newModel
//                    }
//                }
//            }
//        } else {
//            for indexPath in indexPathsSelected {
//                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
//                    if let model = findPhoto.model {
//                        if model.isHearted { /// only unstar if already starred
//                            changedPhotos.append(findPhoto)
//                            do {
//                                try realm.write {
//                                    model.isHearted = false
//                                }
//                            } catch {
//                                print("Error starring photo \(error)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        applyModelSnapshot(changedItems: changedPhotos)
//        sortPhotos(with: currentFilter)
//        applySnapshot()
//        doneWithSelect()
        doneWithSelect()
    }
}
