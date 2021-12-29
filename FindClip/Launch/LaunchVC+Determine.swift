//
//  LaunchVC+Determine.swift
//  FindAppClip1
//
//  Created by Zheng on 3/17/21.
//

import AVFoundation
import UIKit

enum LaunchAction {
    case goToPermissions
    case goToMain
}

extension LaunchViewController {
    func determineAction() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            launchAction = .goToMain
        case .notDetermined:
            launchAction = .goToPermissions
            permissionsViewController.permissionAction = .ask
        case .denied:
            launchAction = .goToPermissions
            permissionsViewController.permissionAction = .goToSettings
            permissionsViewController.changeToSettings = true
        case .restricted:
            launchAction = .goToPermissions
            permissionsViewController.permissionAction = .goToSettings
            permissionsViewController.changeToSettings = true
        @unknown default:
            launchAction = .goToPermissions
            permissionsViewController.permissionAction = .goToSettings
            permissionsViewController.changeToSettings = true
        }
    }
}
