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

            if let realModel = getRealModel?(editableModel) {
                if realModel.isHearted {
                    do {
                        try realm.write {
                            realModel.isHearted = false
                        }
                    } catch {

                    }

                    editableModel.isHearted = false /// also change the editable model
                    updateActions?(.shouldStar)
                    findPhotoChanged?(findPhoto)
                } else {
                    do {
                        try realm.write {
                            realModel.isHearted = true
                        }
                    } catch {

                    }

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

            }
            
            let editableModel = EditableHistoryModel()
            editableModel.assetIdentifier = assetIdentifier
            editableModel.isHearted = true
            editableModel.isTakenLocally = false
            
            findPhoto.editableModel = editableModel
            
            updateActions?(.shouldNotStar)
            findPhotoChanged?(findPhoto)
        }
        
        if
            let photoExists = checkIfPhotoExists?(findPhoto),
            photoExists == false
        {
            removeCurrentSlide()
        }
    }
}
