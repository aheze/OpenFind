//
//  PhotosVC+Star.swift
//  Find
//
//  Created by Zheng on 1/13/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func star(_ shouldStar: Bool) {
        var changedPhotos = [FindPhoto]()
        if shouldStar {
            for indexPath in indexPathsSelected {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    if let editableModel = findPhoto.editableModel {
                        if let realModel = getRealRealmModel(from: editableModel) {
                            if !realModel.isHearted { /// only star if not starred
                                changedPhotos.append(findPhoto)
                                do {
                                    try realm.write {
                                        realModel.isHearted = true
                                    }
                                } catch {
                                    print("Error starring photo \(error)")
                                }
                                editableModel.isHearted = true /// also change the editable model
                            }
                        }
                    } else {
                        changedPhotos.append(findPhoto)
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
                        
                        let editableModel = EditableHistoryModel()
                        editableModel.assetIdentifier = assetIdentifier
                        editableModel.isHearted = true
                        editableModel.isTakenLocally = false
                        
                        findPhoto.editableModel = editableModel
                    }
                }
            }
        } else {
            for indexPath in indexPathsSelected {
                if let findPhoto = dataSource.itemIdentifier(for: indexPath) {
                    if let editableModel = findPhoto.editableModel {
                        if let realModel = getRealRealmModel(from: editableModel) {
                            if realModel.isHearted { /// only unstar if already starred
                                changedPhotos.append(findPhoto)
                                do {
                                    try realm.write {
                                        realModel.isHearted = false
                                    }
                                } catch {
                                    print("Error starring photo \(error)")
                                }
                                editableModel.isHearted = false /// also change the editable model
                            }
                        }
                    }
                }
            }
        }
        
        applyModelSnapshot(changedItems: changedPhotos)
        sortPhotos(with: currentFilter)
        applySnapshot()
        doneWithSelect()
        
    }
}
