//
//  PhotosMigrationController+Permissions.swift
//  Find
//
//  Created by Zheng on 1/6/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Photos
import UIKit

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
            break
        }
        
        switch permissionAction {
        case .notDetermined:
            if #available(iOS 14, *) {
                getAdvancedPhotoAccess()
            } else {
                getPhotoAccess()
            }
        case .goToSettings:
            let allowAccessText = NSLocalizedString("universal-allowAccessToPhotoLibrary", comment: "")
            let needsPermissionToMovePhotos = NSLocalizedString("needsPermissionToMovePhotos", comment: "")
            
            let alert = UIAlertController(title: allowAccessText, message: needsPermissionToMovePhotos, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Multipurpose def=Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("universal-goToSettings", comment: ""), style: UIAlertAction.Style.default, handler: { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }))
            present(alert, animated: true, completion: nil)
        case .restricted:
            let restrictedText = NSLocalizedString("restrictedText", comment: "")
            let findCouldNotAccess = NSLocalizedString("findCouldNotAccess", comment: "")
            let okText = NSLocalizedString("okText", comment: "")
            
            let alert = UIAlertController(title: restrictedText, message: findCouldNotAccess, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .allowed, .limited:
            writeToPhotos(editablePhotos: editablePhotosToMigrate, baseURL: folderURL)
        }
    }
    
    @available(iOS 14, *)
    func getAdvancedPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                self.getPermissionsAndWrite()
            }
        }
    }
    
    func getPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.getPermissionsAndWrite()
            }
        }
    }
}
