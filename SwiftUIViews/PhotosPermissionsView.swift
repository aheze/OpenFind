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
                title: "Find Photos",
                description: "Finding photos requires permission to access the photo library. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Allow Access"
            ) {
                model.requestAuthorization()
            }
        default:
            PermissionsActionView(
                title: "Find Photos",
                description: "Finding photos requires permission to access the photo library. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
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
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image("PhotosPermissions")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)

                Text(title)
                    .font(UIFont.preferredFont(forTextStyle: .title1).font)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(description)
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Button(action: action) {
                Text(actionLabel)
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold).font)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                    .background(
                        LinearGradient(
                            colors: [
                                Colors.accent.color,
                                Colors.accent.offset(by: 0.02).color
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(12)
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
