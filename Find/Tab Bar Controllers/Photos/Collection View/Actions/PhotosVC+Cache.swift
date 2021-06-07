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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIAccessibility.post(notification: .announcement, argument: "Caching complete.")
        }
        
        var paths = [IndexPath]()
        for photo in photos {
            if let path = dataSource.indexPath(for: photo) {
                paths.append(path)
            }
        }
        reloadPaths(changedPaths: paths)
        
        sortPhotos(with: photoFilterState)
        applySnapshot()
        
    }
}

extension PhotosViewController {
    func cache(_ shouldCache: Bool) {
        
        if TipViews.inTutorial {
            TipViews.finishTutorial()
        }
        
        var selectedPhotos = [FindPhoto]()
        for indexPath in indexPathsSelected {
            if let item = dataSource.itemIdentifier(for: indexPath) {
                selectedPhotos.append(item)
            }
        }
        
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
            
            cacheController.photosToCache = selectedPhotos
            cacheController.getRealRealmModel = { [weak self] object in
                guard let self = self else { return nil }
                if let realObject = self.getRealRealmModel(from: object) {
                    return realObject
                } else {
                    return nil
                }
            }
            cacheController.finishedCache = self
            cacheController.view.layer.cornerRadius = 10
            
            selectButtonSelected = false
            SwiftEntryKit.dismiss()
            collectionView.allowsMultipleSelection = false
            
            SwiftEntryKit.display(entry: cacheController, using: attributes)
        } else {
            
            let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
            let clearThisCacheQuestion = NSLocalizedString("clearThisCacheQuestion", comment: "Multifile def=Clear this photo's cache?")
            let cachingAgainTakeAWhile = NSLocalizedString("cachingAgainTakeAWhile", comment: "Multifile def=Caching again will take a while...")
            let clear = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
            
            let alert = UIAlertController(title: clearThisCacheQuestion, message: cachingAgainTakeAWhile, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: clear, style: UIAlertAction.Style.destructive, handler: { _ in
                var changedIndexPaths = [IndexPath]()
                for findPhoto in selectedPhotos {
                    if let editableModel = findPhoto.editableModel {
                        if let realModel = self.getRealRealmModel(from: editableModel)  {
                            if realModel.isDeepSearched { /// only unstar if already starred
                                
                                if let indexPath = self.dataSource.indexPath(for: findPhoto) {
                                    changedIndexPaths.append(indexPath)
                                }
                                do {
                                    try self.realm.write {
                                        realModel.isDeepSearched = false
                                        self.realm.delete(realModel.contents)
                                    }
                                } catch {
                                    print("Error starring photo \(error)")
                                }
                                editableModel.isDeepSearched = false
                                editableModel.contents.removeAll()
                            }
                        }
                    }
                }
                self.reloadPaths(changedPaths: changedIndexPaths)
                self.sortPhotos(with: self.photoFilterState)
                self.applySnapshot()
            }))
            alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect =  CGRect(x: (self.view.bounds.width / 2) - 40, y: self.view.bounds.height - 80, width: 80, height: 80)
            }
            self.present(alert, animated: true, completion: nil)
            
            
        }
        doneWithSelect()
    }
    
}
