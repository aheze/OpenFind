//
//  CameraPermissionsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import AVFoundation
import SwiftUI

class CameraPermissionsViewModel: ObservableObject {
    @Published var currentStatus: AVAuthorizationStatus

    var permissionsGranted: (() -> Void)?

    init() {
        currentStatus = CameraPermissionsViewModel.checkAuthorizationStatus()
    }

    func requestAuthorization() {
        func setStatus(to status: AVAuthorizationStatus) {
            withAnimation {
                self.currentStatus = status
            }
        }
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.permissionsGranted?()
                }
                let status = CameraPermissionsViewModel.checkAuthorizationStatus()
                setStatus(to: status)
            }
        }
    }

    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    static func checkAuthorizationStatus() -> AVAuthorizationStatus {
        var action: AVAuthorizationStatus

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            action = .authorized
        } else if status == .notDetermined {
            action = .notDetermined
        } else {
            action = .denied
        }

        return action
    }
}

struct CameraPermissionsView: View {
    @ObservedObject var model: CameraPermissionsViewModel
    var body: some View {
        switch model.currentStatus {
        case .notDetermined, .restricted:
            PermissionsActionView(
                image: "CameraPermissions",
                title: "Camera Permissions",
                description: "Finding text in the live video feed requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Continue",
                dark: true
            ) {
                model.requestAuthorization()
            }
        default:
            PermissionsActionView(
                image: "CameraPermissions",
                title: "Camera Permissions",
                description: "Finding text in the live video feed requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Go to Settings",
                dark: true
            ) {
                model.goToSettings()
            }
        }
    }
}
