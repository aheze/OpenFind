//
//  PhotosPermissionsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

class PhotosPermissionsViewModel: ObservableObject {
    @Published var currentStatus: PHAuthorizationStatus

    var permissionsGranted: (() -> Void)?

    init() {
        currentStatus = PhotosPermissionsViewModel.checkAuthorizationStatus()
    }

    func requestAuthorization() {
        func setStatus(to status: PHAuthorizationStatus) {
            withAnimation {
                self.currentStatus = status
            }
        }
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self.permissionsGranted?()
                    }
                    setStatus(to: status)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.permissionsGranted?()
                    }
                    setStatus(to: status)
                }
            }
        }
    }

    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    static func checkAuthorizationStatus() -> PHAuthorizationStatus {
        var action: PHAuthorizationStatus
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .authorized || status == .limited {
                action = .authorized
            } else if status == .notDetermined {
                action = .notDetermined
            } else {
                action = .denied
            }

        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized {
                action = .authorized
            } else if status == .notDetermined {
                action = .notDetermined
            } else {
                action = .denied
            }
        }

        return action
    }
}

struct PhotosPermissionsView: View {
    @ObservedObject var model: PhotosPermissionsViewModel
    var body: some View {
        switch model.currentStatus {
        case .notDetermined, .restricted:
            PermissionsActionView(
                title: "Find from Photos",
                description: "Find needs permissions to access the photo library.",
                actionLabel: "Allow Access"
            ) {
                model.requestAuthorization()
            }
        default:
            PermissionsActionView(
                title: "Find from Photos",
                description: "Find needs permissions to access the photo library.",
                actionLabel: "Go to Settings"
            ) {
                model.goToSettings()
            }
        }
    }
}

struct PermissionsActionView: View {
    let title: String
    let description: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Text(description)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text(actionLabel)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(36)
    }
}
