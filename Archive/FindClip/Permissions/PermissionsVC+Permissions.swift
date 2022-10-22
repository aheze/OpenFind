//
//  PermissionsVC+Permissions.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import AppClip
import AVFoundation
import UIKit

enum PermissionAction {
    case ask
    case goToSettings
    case authorized
}

extension PermissionsViewController {
    func requestAccess() {
        switch permissionAction {
        case .ask:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { grantedAccess in
                if grantedAccess {
                    self.granted?()
                } else {
                    self.permissionAction = .goToSettings
                    DispatchQueue.main.async {
                        self.allowAccessButton.setTitle("Go to Settings", for: .normal)
                    }
                }
            })
        case .goToSettings:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        case .authorized:
            granted?()
        }
    }
}
