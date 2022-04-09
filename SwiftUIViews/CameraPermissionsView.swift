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
            CameraPermissionsActionView(
                title: "Camera Permissions",
                description: "Finding text in real life requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Allow Access"
            ) {
                model.requestAuthorization()
            }
        default:
            CameraPermissionsActionView(
                title: "Camera Permissions",
                description: "Finding text in real life requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Go to Settings"
            ) {
                model.goToSettings()
            }
        }
    }
}

struct CameraPermissionsActionView: View {
    let title: String
    let description: String
    let actionLabel: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image("CameraPermissions")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)

                Text(title)
                    .font(UIFont.preferredFont(forTextStyle: .title1).font)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(description)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            .foregroundColor(.white)

            Button(action: action) {
                Text(actionLabel)
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold).font)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                    .background(
                        LinearGradient(
                            colors: [
                                Colors.accent.toColor(.black, percentage: 0.75).color,
                                Colors.accent.toColor(.black, percentage: 0.75).withAlphaComponent(0.5).color
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

struct CameraPermissionsViewTester: View {
    @StateObject var model = CameraPermissionsViewModel()
    var body: some View {
        CameraPermissionsView(model: model)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accent)
    }
}

struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsViewTester()
    }
}
