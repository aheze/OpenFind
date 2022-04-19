//
//  Camera.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class CameraController {
    var model: CameraViewModel
    var tabViewModel: TabViewModel
    var photosPermissionsViewModel: PhotosPermissionsViewModel
    var realmModel: RealmModel
    var viewController: CameraViewController

    init(
        model: CameraViewModel,
        tabViewModel: TabViewModel,
        photosPermissionsViewModel: PhotosPermissionsViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.photosPermissionsViewModel = photosPermissionsViewModel
        self.realmModel = realmModel

        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CameraViewController") { coder in
            CameraViewController(
                coder: coder,
                model: model,
                tabViewModel: tabViewModel,
                photosPermissionsViewModel: photosPermissionsViewModel,
                realmModel: realmModel
            )
        }

        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
