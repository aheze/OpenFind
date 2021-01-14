//
//  PhotosVC+Realm.swift
//  Find
//
//  Created by Zheng on 1/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func getRealmObjects() {
        photoObjects = realm.objects(HistoryModel.self)
    }
//    func getRealRealmObject(from unmanagedObject: HistoryModel) -> HistoryModel? {
//        if
//            let photoObjects = photoObjects,
//            let firstObject = (photoObjects.filter {$0.assetIdentifier == unmanagedObject.assetIdentifier }).first
//        {
//            return firstObject
//        }
//        return nil
//    }
    func getRealRealmModel(from editableModel: EditableHistoryModel) -> HistoryModel? {
        if
            let photoObjects = photoObjects,
            let firstObject = (photoObjects.filter {$0.assetIdentifier == editableModel.assetIdentifier }).first
        {
            return firstObject
        }
        return nil
    }
}
