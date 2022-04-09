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
                description: "Finding text in real life requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Allow Access",
                dark: true
            ) {
                model.requestAuthorization()
            }
        default:
            PermissionsActionView(
                image: "CameraPermissions",
                title: "Camera Permissions",
                description: "Finding text in real life requires permission to access the camera. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone.",
                actionLabel: "Go to Settings",
                dark: true
            ) {
                model.goToSettings()
            }
        }
    }
}

struct PermissionsActionView: View {
    let image: String
    let title: String
    let description: String
    let actionLabel: String
    let dark: Bool
    let action: () -> Void

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        Color.clear.overlay(
            AdaptiveStack(vertical: verticalSizeClass != .compact, spacing: 32) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)

                let alignment: HorizontalAlignment = verticalSizeClass != .compact ? .center : .leading
                let labelAlignment: Alignment = verticalSizeClass != .compact ? .center : .leading
                let textAlignment: TextAlignment = verticalSizeClass != .compact ? .center : .leading

                VStack(alignment: alignment, spacing: 12) {
                    Text(title)
                        .font(UIFont.preferredFont(forTextStyle: .title1).font)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(dark ? UIColor.white.color : UIColor.label.color)

                    Text(description)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: labelAlignment)
                        .multilineTextAlignment(textAlignment)
                        .foregroundColor(dark ? UIColor.white.withAlphaComponent(0.75).color : UIColor.secondaryLabel.color)

                    Button(action: action) {
                        let colors = dark
                            ? [
                                Colors.accent.toColor(.black, percentage: 0.75).color,
                                Colors.accent.toColor(.black, percentage: 0.75).withAlphaComponent(0.5).color
                            ]
                            : [
                                Colors.accent.color,
                                Colors.accent.offset(by: 0.02).color
                            ]

                        Text(actionLabel)
                            .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .semibold).font)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                            .background(
                                LinearGradient(
                                    colors: colors,
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, verticalSizeClass != .compact ? 36 : 0)
            }
        )
        .edgesIgnoringSafeArea(.all)
        .padding(.horizontal, verticalSizeClass != .compact ? 0 : 64)
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

@available(iOS 15.0, *)
struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsViewTester()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct AdaptiveStack<Content: View>: View {
    let vertical: Bool
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(vertical: Bool, horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.vertical = vertical
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if vertical {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }
        }
    }
}
