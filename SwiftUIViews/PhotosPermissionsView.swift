//
//  PhotosPermissionsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

extension PHAuthorizationStatus {
    func isGranted() -> Bool {
        if #available(iOS 14, *) {
            if self == .authorized || self == .limited {
                return true
            }
        } else {
            if self == .authorized {
                return true
            }
        }
        return false
    }
}

class PhotosPermissionsViewModel: ObservableObject {
    @Published var currentStatus: PHAuthorizationStatus

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
                    setStatus(to: status)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
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
                image: "PhotosPermissions",
                title: "Find Photos",
                description: "Finding photos requires permission to access the photo library. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Allow Access",
                dark: false
            ) {
                model.requestAuthorization()
            }
        default:
            PermissionsActionView(
                image: "PhotosPermissions",
                title: "Find Photos",
                description: "Finding photos requires permission to access the photo library. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Go to Settings",
                dark: false
            ) {
                model.goToSettings()
            }
        }
    }
}

struct PhotosPermissionsViewTester: View {
    @StateObject var model = PhotosPermissionsViewModel()
    var body: some View {
        PhotosPermissionsView(model: model)
    }
}

struct PhotosPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosPermissionsViewTester()
    }
}
