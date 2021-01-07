//
//  PhotosMigrationController+Permissions.swift
//  Find
//
//  Created by Zheng on 1/6/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

extension PhotosMigrationController {
    func getPermissionsAndWrite() {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        var permissionAction = PermissionAction.notDetermined
        switch status {
        case .notDetermined:
            permissionAction = .notDetermined
        case .restricted:
            permissionAction = .restricted
        case .denied:
            permissionAction = .goToSettings
        case .authorized:
            permissionAction = .allowed
        case .limited:
            permissionAction = .limited
        @unknown default:
            print("unknown default")
        }
        
        switch permissionAction {
        
        case .notDetermined:
            if #available(iOS 14, *) {
                getAdvancedPhotoAccess()
            } else {
                getPhotoAccess()
            }
        case .goToSettings:
            let alert = UIAlertController(title: "Allow Access to Photo Library", message: "Find needs permission to move your photos", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Go to Settings", style: UIAlertAction.Style.default, handler: { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        case .restricted:
            let alert = UIAlertController(title: "Restricted", message: "Find could not access your photo library.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .allowed, .limited:
            writeToPhotos(editablePhotos: editablePhotosToMigrate, baseURL: folderURL)
        }
        
    }
    
    @available(iOS 14, *)
    func getAdvancedPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            if status == .authorized || status == .limited {
                self.getPermissionsAndWrite()
            }
        }
    }
    
    func getPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.getPermissionsAndWrite()
            }
        }
    }

}
