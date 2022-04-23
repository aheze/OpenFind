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
    @State var present = false
    @State var presentingUUID = UUID()
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(16)

            Text("Scan to download Find")
                .foregroundColor(UIColor.secondaryLabel.color)
                .font(UIFont.preferredFont(forTextStyle: .title1).font)

            Image("AppQRCode")
                .resizable()
                .aspectRatio(contentMode: .fit)

            Button {
                present = true
            } label: {
                Text("getfind.app")
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .font(UIFont.preferredFont(forTextStyle: .title1).font)
            }

            Spacer()
        }
        .foregroundColor(UIColor.label.color)
        .padding(.horizontal, 32)
        .padding(.top, 48)
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .top,
                    ]
                )
                $0.presentation.animation = .spring()
                $0.presentation.transition = .move(edge: .top)
                $0.dismissal.animation = .spring(response: 3, dampingFraction: 0.8, blendDuration: 1)
                $0.dismissal.transition = .move(edge: .top)
                $0.dismissal.mode = [.dragUp]
                $0.dismissal.dragDismissalProximity = 0.1
            }
        ) {
            NotificationViewPopover(icon: "doc.on.doc", text: "Link copied!", color: Colors.accent)
                .onAppear {
                    presentingUUID = UUID()
                    let currentID = presentingUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if currentID == presentingUUID {
                            present = false
                        }
                    }
                }
        }
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
            .font(.system(size: 19, weight: .medium))
            .frame(width: 36, height: 36)
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
    var body: some View {
        HStack {
            NotificationImage(icon, color: color)
            Text(text)
            Spacer()
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
