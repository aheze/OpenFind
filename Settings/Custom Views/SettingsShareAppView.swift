//
//  SettingsLinks.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class SettingsShareAppViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground

        self.title = "Share App"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.dismissSelf), imageName: "Dismiss")

        let containerView = SettingsShareAppView()
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
}

struct SettingsShareAppView: View {
    @State var copied = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .cornerRadius(16)

                VStack(alignment: .leading) {
                    Text("OpenFind")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .semibold).font)

                    Text("An app to find text in real life.")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .background(
                LinearGradient(
                    colors: [
                        Colors.accent.color,
                        Colors.accent.toColor(.black, percentage: 0.2).color
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)

            Button {
                UIPasteboard.general.url = URL(string: "https://open.getfind.app")
                withAnimation {
                    copied = true
                }

                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

            } label: {
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.on.doc")

                        Text("Copy Link")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if copied {
                        Image(systemName: "checkmark")
                            .transition(.scale)
                    }
                }
                .font(UIFont.preferredCustomFont(forTextStyle: .title2, weight: .medium).font)
                .foregroundColor(.accent)
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                .blueBackground()
            }

            VStack(spacing: 0) {
                Image("AppQRCode")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(UIColor.label.color)

                Text("Scan to download Find")
                    .foregroundColor(.accent)
                    .font(UIFont.preferredFont(forTextStyle: .title3).font)
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 24, trailing: 20))
            .blueBackground()

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
}

struct SettingsLinksButton: View {
    var iconName: String
    var title: String
    var color: UIColor
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            LinearGradient(
                colors: [
                    color.color,
                    color.offset(by: 0.05).color,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                HStack {
                    Image(systemName: iconName)
                    Text(title)
                }
                .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                .foregroundColor(Color.white)
            )
            .cornerRadius(10)
        }
    }
}

struct NotificationImage: View {
    let imageName: String
    let color: UIColor
    init(_ imageName: String, color: UIColor) {
        self.imageName = imageName
        self.color = color
    }

    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .medium))
            .frame(width: 38, height: 38)
            .background(
                LinearGradient(
                    colors: [
                        color.color,
                        color.offset(by: 0.06).color,
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(10)
    }
}

struct NotificationViewPopover: View {
    let icon: String
    let text: String
    let color: UIColor
    var url: String?

    var body: some View {
        HStack {
            NotificationImage(icon, color: color)

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let urlString = url {
                Button {
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "arrow.up.right")
                        .font(UIFont.preferredFont(forTextStyle: .title3).font)
                        .foregroundColor(.accent)
                }
            }
        }
        .frame(maxWidth: 600)
        .padding()
        .background(VisualEffectView(.regular))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(UIColor.label.withAlphaComponent(0.25).color, lineWidth: 1)
        )
    }
}
