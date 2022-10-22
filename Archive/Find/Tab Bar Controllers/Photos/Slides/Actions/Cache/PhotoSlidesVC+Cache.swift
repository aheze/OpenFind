//
//  PhotoSlidesVC+Cache.swift
//  Find
//
//  Created by Zheng on 1/19/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftEntryKit
import UIKit

class TemporaryCachingPhoto {
    var cachePressed = false
    var contents = [EditableSingleHistoryContent]()
}

extension PhotoSlidesViewController {
    func cachePhoto() {
        let findPhoto = resultPhotos[currentIndex].findPhoto
        
        if
            let editableModel = findPhoto.editableModel,
            let realModel = getRealModel?(editableModel),
            realModel.isDeepSearched,
            temporaryCachingPhoto?.cachePressed ?? true
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
                    } catch {}
                    editableModel.isDeepSearched = false /// also change the editable model
                    editableModel.contents.removeAll()
                    
                    self.temporaryCachingPhoto = nil
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
            alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: { _ in
                self.focusCacheButton?()
            }))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: (view.bounds.width / 2) - 40, y: view.bounds.height - 80, width: 80, height: 80)
            }
            present(alert, animated: true, completion: nil)
            
        } else {
            if let temporaryCachingPhoto = temporaryCachingPhoto, temporaryCachingPhoto.cachePressed {
                temporaryCachingPhoto.cachePressed = false
                updateActions?(.shouldCache)
                messageView.hideMessages()
                pageViewController.dataSource = self
            } else {
                startCaching()
            }
        }
    }
}
