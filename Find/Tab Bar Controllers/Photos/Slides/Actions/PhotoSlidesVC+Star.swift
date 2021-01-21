//
//  PhotoSlidesVC+Star.swift
//  Find
//
//  Created by Zheng on 1/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func starPhoto() {
        let findPhoto = resultPhotos[currentIndex].findPhoto
        
        if let editableModel = findPhoto.editableModel {
            print("has editable model!!!")
            if let realModel = getRealModel?(editableModel) {
                if realModel.isHearted {
                    do {
                        try realm.write {
                            realModel.isHearted = false
                        }
                    } catch {
                        print("Error starring photo \(error)")
                    }
                    print("make false")
                    editableModel.isHearted = false /// also change the editable model
                    updateActions?(.shouldStar)
                    findPhotoChanged?(findPhoto)
                } else {
                    do {
                        try realm.write {
                            realModel.isHearted = true
                        }
                    } catch {
                        print("Error starring photo \(error)")
                    }
                    print("make true")
                    editableModel.isHearted = true /// also change the editable model
                    updateActions?(.shouldNotStar)
                    findPhotoChanged?(findPhoto)
                }
            }
        } else {
            let assetIdentifier = findPhoto.asset.localIdentifier
            let newModel = HistoryModel()
            newModel.assetIdentifier = assetIdentifier
            newModel.isHearted = true
            newModel.isTakenLocally = false
            
            do {
                try realm.write {
                    realm.add(newModel)
                }
            } catch {
                print("Error saving model \(error)")
            }
            updateActions?(.shouldStar)
            findPhotoChanged?(findPhoto)
            
            let editableModel = EditableHistoryModel()
            editableModel.assetIdentifier = assetIdentifier
            editableModel.isHearted = true
            editableModel.isTakenLocally = false
            
            findPhoto.editableModel = editableModel
        }
        
        if
            let photoExists = checkIfPhotoExists?(findPhoto),
            photoExists == false
        {
            removeCurrentSlide()
        }
    }
}
